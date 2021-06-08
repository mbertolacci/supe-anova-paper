source('scripts/partials/base.R')
source('scripts/partials/display.R')
source('scripts/partials/tables.R')

library(sf)
library(tidyr)

region_sf <- readRDS('intermediates/region-sf.rds')
clustering_df <- readRDS('intermediates/clustering.rds')

output <- region_sf %>%
  left_join(
    clustering_df %>%
      select(-clustering) %>%
      unnest(regions),
    by = 'region_code'
  ) %>%
  mutate(
    cluster = sprintf('Group %d', cluster)
  ) %>%
  ggplot() +
    geom_sf(
      mapping = aes(fill = cluster),
      colour = '#555555',
      size = 0.1
    ) +
    geom_path(
      data = data.frame(
        longitude = c(-180, 180, 180, -180, -180),
        latitude = c(-90, -90, 90, 90, -90)
      ),
      mapping = aes(longitude, latitude),
      colour = 'black',
      size = 0.1
    ) +
    # scale_fill_manual(
    #   values = c(
    #     '#8da0cb',
    #     '#66c2a5',
    #     '#fc8d62',
    #     '#e78ac3'
    #   )
    # ) +
    scale_fill_brewer(palette = 'Accent') +
    facet_wrap(~ season) +
    labs(x = NULL, y = NULL, fill = NULL) +
    theme(
      legend.position = 'right',
      plot.margin = margin(),
      panel.border = element_blank(),
      panel.grid = element_blank(),
      axis.title = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank()
    )

ggsave(
  'figures/clustering-map.pdf',
  output,
  width = 17,
  height = 9,
  units = 'cm',
  bg = 'transparent'
)
