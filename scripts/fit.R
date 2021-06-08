source('scripts/partials/base.R')
source('scripts/partials/tables.R')
source('scripts/partials/fit.R')

library(nlme, exclude = 'collapse')
library(tidyr)
library(parallel)
library(Matrix, exclude = c('expand', 'pack', 'unpack'))

gamma_shape_ratio <- function(ratio, p_lower, p_upper) {
  .softplus <- function(x) ifelse(x > 30, x, log1p(exp(x)))

  stopifnot(p_lower < p_upper)

  .softplus(uniroot(
    function(x) {
      theoretical <- qgamma(c(p_upper, p_lower), shape = .softplus(x), rate = 1)
      theoretical[1] / theoretical[2] - ratio
    },
    lower = -10,
    upper = 10,
    extendInt = 'yes',
    tol = sqrt(.Machine$double.eps)
  )$root)
}

mip_fluxes <- fst::read_fst('intermediates/mip-fluxes.fst')
clustering_df <- readRDS('intermediates/clustering.rds')

mip_fluxes_clustering <- mip_fluxes %>%
  left_join(
    clustering_df %>%
      select(-clustering) %>%
      unnest(regions),
    by = c('season', 'region_code')
  )

part_df <- expand.grid(
  cluster = sort(unique(mip_fluxes_clustering$cluster)),
  season = sort(unique(mip_fluxes_clustering$season)),
  configuration = sort(unique(mip_fluxes_clustering$configuration))
)

fit_df <- bind_rows(pbmcapply::pbmclapply(seq_len(nrow(part_df)), function(i) {
  cluster_i <- part_df$cluster[i]
  season_i <- part_df$season[i]
  configuration_i <- part_df$configuration[i]

  df <- mip_fluxes_clustering %>%
    filter(
      cluster == cluster_i,
      season == season_i,
      configuration == configuration_i
    ) %>%
    select(-cluster, -season, -configuration)

  if (nrow(df) == 0) return(NULL)

  region_code <- droplevels(df$region_code)
  month_region <- droplevels(df$month_region)
  tryCatch({
    fit <- fit_model(
      df$flux,
      region_code,
      month_region,
      df$model,
      scale_factor = sd(df$flux) / 2,
      iterlim = 1000,
      print.level = 0,
      stepmax = 1000000,
      shape_tau_model = gamma_shape_ratio(4, 0.025, 0.975),
      best_of = 3
    )
  }, error = function(e) {
    print(i)
    stop(e)
  })

  model_climatological_weights <- fit$tau_model / sum(fit$tau_model)
  climatological_weights <- tibble(
    model = factor(MODELS, levels = MODELS),
    weight = model_climatological_weights
  )

  model_prediction_weights <- c(fit$tau_model, fit$tau_re) / (fit$tau_re + sum(fit$tau_model))
  prediction_weights <- tibble(
    model = factor(c(MODELS, 'Climatology'), levels = c(MODELS, 'Climatology')),
    weight = model_prediction_weights
  )

  predicted_fluxes <- df %>%
    mutate(flux_prediction = fit$prediction) %>%
    distinct(month_start, region_code, month_region, .keep_all = TRUE) %>%
    mutate(
      flux = flux_prediction,
      flux_variance = fit$prediction_variance
    ) %>%
    select(month_start, region_code, flux, flux_variance)

  model_fluxes <- df %>%
    mutate(
      flux_predicted = fit$prediction,
      flux_variance = 1 / fit$tau_model[model]
    )

  tibble(
    cluster = cluster_i,
    season = season_i,
    configuration = configuration_i,
    model_fluxes = list(model_fluxes),
    predicted_fluxes = list(predicted_fluxes),
    climatological_weights = list(climatological_weights),
    prediction_weights = list(prediction_weights),
    fit = list(fit)
  )
}, mc.cores = parallel::detectCores(), ignore.interactive = TRUE))

saveRDS(fit_df, 'intermediates/fit.rds')
