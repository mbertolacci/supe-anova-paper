source('scripts/partials/base.R')
source('scripts/partials/tables.R')

library(sf)

region_sf <- readRDS('intermediates/region-sf.rds')

region_centroids <- region_sf %>%
  st_centroid() %>%
  st_coordinates()

region_centroids[which(REGION_CODES == 'T12'), 1] <- 160
region_centroids[which(REGION_CODES == 'T13'), 1] <- 160
region_centroids[which(REGION_CODES == 'T15'), 1] <- -120

saveRDS(region_centroids, 'intermediates/region-centroids.rds')
