source('scripts/partials/base.R')
source('scripts/partials/tables.R')

library(sf)
library(raster, warn.conflicts = FALSE)

with_nc_file(list(fn = 'data/oco2_regions_l4mip_v7.nc'), {
  v <- function(...) ncvar_get(fn, ...)

  mip_region_df <- tibble(expand.grid(
    longitude = v('longitude'),
    latitude = v('latitude')
  )) %>%
    mutate(
      region = as.vector(apply(v('mip_masks')[, , 1 : 27], 1 : 2, function(x) {
        which(x == 1)[1]
      }))
    )
})

mip_region_raster <- raster::raster('data/oco2_regions_l4mip_v7.nc', varname = 'grid_cell_area')
values(mip_region_raster) <- t(matrix(mip_region_df$region, nrow = ncol(mip_region_raster)))[
  180 : 1,
]
names(mip_region_raster) <- 'region'

mip_region_poly <- mip_region_raster %>%
  rasterToPolygons(dissolve = TRUE)

mip_region_sf <- mip_region_poly %>%
  st_as_sf() %>%
  mutate(
    region_code = REGION_CODES[region]
  ) %>%
  arrange(region_code)

saveRDS(mip_region_sf, 'intermediates/region-sf.rds')
