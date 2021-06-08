source('scripts/partials/base.R')
source('scripts/partials/display.R')
source('scripts/partials/tables.R')

mip_fluxes <- fst::read_fst('intermediates/mip-fluxes.fst') %>%
  filter(configuration == 'LN') %>%
  mutate(
    flux_variance = NA,
    part = ifelse(
      region_code %in% OCEAN_REGION_CODES,
      'Global Ocean',
      'Global Land'
    )
  ) %>%
  group_by(part, model, month_start) %>%
  summarise(
    flux = sum(flux)
  )

unweighted_fluxes <- mip_fluxes %>%
  group_by(part, month_start) %>%
  summarise(
    flux_variance = var(flux) / n(),
    flux = mean(flux)
  ) %>%
  ungroup() %>%
  mutate(which = 'Unweighted average')

output <- ggplot(mapping = aes(month_start, flux)) +
  geom_line(
    data = mip_fluxes,
    mapping = aes(group = model),
    colour = '#bbbbbb'
  ) +
  geom_point(
    data = unweighted_fluxes,
    shape = 3,
    size = 3,
    stroke = 0.9
  ) +
  facet_wrap(~ part, ncol = 1, scales = 'free_y') +
  theme(
    plot.margin = margin(0, 0.8, 0, 0, unit = 'cm'),
  ) +
  labs(
    x = 'Month',
    y = 'Flux [PgC / month]',
    colour = NULL,
    linetype = NULL
  )

ggsave(
  'figures/flux-land-ocean-ln.pdf',
  output,
  width = 17,
  height = 9,
  units = 'cm',
  bg = 'transparent'
)
