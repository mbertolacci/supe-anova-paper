source('scripts/partials/base.R')
source('scripts/partials/tables.R')

set.seed(20210215)

kmeans_within <- function(x, threshold = 0.8, max_centers = 10) {
  for (centers in 1 : max_centers) {
    output <- kmeans(x, centers = centers, iter.max = 100, nstart = 1000)
    if (output$betweenss / output$totss > threshold) {
      return(output)
    }
  }
  stop('failed')
}

relabel_scale <- function(clusters, centers) {
  stopifnot(is.integer(clusters))
  reordered <- as.integer(names(sort(rowSums(centers ^ 2))))
  match(clusters, reordered)
}

mip_fluxes <- fst::read_fst('intermediates/mip-fluxes.fst')

residual_df <- mip_fluxes %>%
  filter(
    configuration == 'LN'
  ) %>%
  group_by(month_start, region_code) %>%
  mutate(
    flux_resid = flux - quantile(flux, probs = 0.5)
  ) %>%
  ungroup()

clustering_df <- residual_df %>%
  mutate(
    season = to_season(month_start)
  ) %>%
  group_by(season) %>%
  group_modify(~ {
    stdevs <- .x %>%
      group_by(region_code) %>%
      summarise(
        stdev = mad(flux_resid, center = 0)
      ) %>%
      pull(stdev)
    output <- kmeans_within(log10(stdevs), threshold = 0.9)
    tibble(
      clustering = list(output),
      regions = list(tibble(
        region_code = factor(REGION_CODES),
        stdev = stdevs,
        cluster = factor(relabel_scale(output$cluster, output$centers)),
        cluster_center = 10 ^ output$centers[output$cluster, 1]
      ))
    )
  }) %>%
  ungroup()

saveRDS(clustering_df, 'intermediates/clustering.rds')
