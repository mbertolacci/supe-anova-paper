source('scripts/partials/base.R')
source('scripts/partials/display.R')
source('scripts/partials/tables.R')

library(tidyr)
library(patchwork)

fit_df <- readRDS('intermediates/fit.rds')

model_fluxes <- fit_df %>%
  unnest(cols = 'model_fluxes') %>%
  mutate(
    flux_sd = sqrt(flux_variance),
    flux_std = (flux - flux_predicted) / flux_sd
  )

all_plots <- lapply(CONFIGURATIONS, function(configuration_i) {
  model_fluxes %>%
    filter(configuration == configuration_i) %>%
    mutate(cluster = sprintf('Group %d', cluster)) %>%
    ggplot(aes(sample = flux_std)) +
      geom_qq(size = 0.2) +
      geom_abline(intercept = 0, slope = 1, linetype = 3) +
      coord_fixed() +
      labs(x = 'Theoretical', y = 'Sample') +
      facet_grid(cluster ~ season) +
      ggtitle(configuration_i) +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1)
      )
})

output <- wrap_plots(all_plots, ncol = 2)

ggsave(
  'figures/qqplots.pdf',
  output,
  width = 17,
  height = 22,
  units = 'cm',
  bg = 'transparent'
)
