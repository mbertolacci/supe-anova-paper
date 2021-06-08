source('scripts/partials/base.R')
source('scripts/partials/display.R')
source('scripts/partials/tables.R')

library(tidyr)
library(patchwork)

fit_df <- readRDS('intermediates/fit.rds')

weight_df <- fit_df %>%
  unnest(cols = 'climatological_weights') %>%
  mutate(
    cluster = sprintf('Group %d', cluster)
  ) %>%
  filter(configuration != 'Prior')

weight_max <- max(weight_df$weight)

outputs <- weight_df %>%
  group_by(configuration) %>%
  group_map(~ {
    ggplot(.x, aes(model, weight, fill = model)) +
      geom_col(
        colour = 'black',
        size = 0.1
      ) +
      facet_grid(season ~ cluster) +
      theme(
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)
      ) +
      MODEL_SCALES$fill +
      theme(
        plot.title = element_text(hjust = 0.5, size = 10),
        plot.margin = margin(0, 0, 0, 0, unit = 'pt'),
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.y = element_text(size = 7),
        strip.text = element_text(size = 7),
        panel.grid.major.x = element_blank()
      ) +
      ylim(c(0, weight_max)) +
      labs(x = NULL, y = expression(hat(w)['s,r']), fill = NULL) +
      ggtitle(.y$configuration[1])
  })

output <- wrap_plots(
  outputs,
  guides = 'collect',
  ncol = 2
) +
  guide_area() &
  guides(
    fill = guide_legend(ncol = 2)
  ) &
  theme(legend.position = 'bottom')

ggsave(
  'figures/climatological-weights.pdf',
  output,
  width = 17,
  height = 10,
  units = 'cm',
  bg = 'transparent'
)
