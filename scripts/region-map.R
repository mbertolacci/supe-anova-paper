source('scripts/partials/base.R')
source('scripts/partials/display.R')
source('scripts/partials/tables.R')

library(sf)

region_sf <- readRDS('intermediates/region-sf.rds')
region_centroids <- readRDS('intermediates/region-centroids.rds')

output <- ggplot() +
  geom_sf(
    data = region_sf,
    colour = '#555555',
    size = 0.1,
    fill = 'white'
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
  geom_text(
    data = cbind(
      as.data.frame(region_sf) %>% dplyr::select(-geometry),
      region_centroids
    ),
    mapping = aes(
      x = X,
      y = Y,
      label = region_code,
      colour = colour
    ),
    colour = 'black'
  ) +
  labs(x = NULL, y = NULL) +
  theme(
    legend.position = 'bottom',
    plot.margin = margin(),
    panel.border = element_blank(),
    panel.grid = element_blank(),
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank()
  )

ggsave(
  'figures/region-map.pdf',
  output,
  width = 17,
  height = 8,
  units = 'cm',
  bg = 'transparent'
)
