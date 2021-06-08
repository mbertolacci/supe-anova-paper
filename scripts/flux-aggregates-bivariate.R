source('scripts/partials/base.R')
source('scripts/partials/display.R')
source('scripts/partials/tables.R')

library(tidyr)
library(patchwork)

aggregate_df <- bind_rows(
  tibble(
    aggregate_name = 'land',
    region_codes = list(setdiff(REGION_CODES, OCEAN_REGION_CODES))
  ),
  tibble(
    aggregate_name = 'ocean',
    region_codes = list(OCEAN_REGION_CODES)
  )
)

aggregate_annual_flux_df <- function(df) {
  aggregate_df %>%
    group_by(aggregate_name) %>%
    group_modify(~ {
      df %>%
        filter(region_code %in% .x$region_codes[[1]]) %>%
        mutate(year = lubridate::year(month_start)) %>%
        group_by(model, configuration, year) %>%
        summarise(
          flux = sum(flux),
          flux_variance = sum(flux_variance)
        )
    }) %>%
    mutate(
      flux_lower = flux - 1.96 * sqrt(flux_variance),
      flux_upper = flux + 1.96 * sqrt(flux_variance)
    )
}

mip_fluxes <- fst::read_fst('intermediates/mip-fluxes.fst') %>%
  mutate(flux_variance = NA)

unweighted_fluxes <- mip_fluxes %>%
  group_by(configuration, month_start, region_code) %>%
  summarise(
    flux_variance = var(flux) / n(),
    flux = mean(flux)
  ) %>%
  ungroup() %>%
  mutate(model = 'Unweighted average')

predicted_fluxes <- readRDS('intermediates/fit.rds') %>%
  unnest(predicted_fluxes) %>%
  ungroup() %>%
  select(configuration, month_start, region_code, flux, flux_variance) %>%
  mutate(model = 'SUPE-ANOVA')

annual_data <- bind_rows(
  mip_fluxes,
  unweighted_fluxes,
  predicted_fluxes
) %>%
  aggregate_annual_flux_df() %>%
  select(aggregate_name, model, configuration, year, flux) %>%
  pivot_wider(names_from = 'aggregate_name', values_from = 'flux') %>%
  mutate(
    is_summary = model %in% c('SUPE-ANOVA', 'Unweighted average')
  )

output <- ggplot() +
  geom_point(
    data = annual_data %>%
      filter(!is_summary) %>%
      mutate(model = factor(model, MODELS)),
    mapping = aes(land, ocean, colour = model),
    size = 2
  ) +
  geom_point(
    data = annual_data %>% filter(is_summary),
    mapping = aes(land, ocean, shape = model),
    size = 3
  ) +
  MODEL_SCALES$colour_darker +
  scale_shape_manual(
    values = c(8, 3)
  ) +
  scale_linetype_manual(
    values = 'dotted'
  ) +
  coord_fixed() +
  guides(
    colour = guide_legend(order = 1),
    shape = guide_legend(order = 2)
  ) +
  facet_grid(year ~ configuration) +
  labs(
    x = expression('Global land flux [PgC '*yr^-1*']'),
    y = expression('Global ocean flux [PgC '*yr^-1*']'),
    shape = NULL,
    colour = NULL
  ) +
  theme(
    legend.spacing.y = unit(0, 'pt')
  )

ggsave(
  'figures/flux-aggregates-bivariate.pdf',
  output,
  width = 17,
  height = 9,
  units = 'cm',
  bg = 'transparent'
)

