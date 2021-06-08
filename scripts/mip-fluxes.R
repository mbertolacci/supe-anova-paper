source('scripts/partials/base.R')
source('scripts/partials/tables.R')

mip_fluxes <- fst::read_fst('intermediates/mip-fluxes-raw.fst') %>%
  filter(
    case %in% c('Prior', 'IS', 'LG', 'LN'),
    region_name != 'TransCom 23: Not optimized',
    startsWith(region_name, 'Trans'),
    type != 'fossil',
    month_start >= '2015-01-01',
    month_start < '2017-01-01'
  ) %>%
  rename(
    model = group,
    configuration = case
  ) %>%
  filter(configuration != 'Prior') %>%
  mutate(
    configuration = factor(configuration, levels = CONFIGURATIONS),
    region_code = factor(REGION_NAME_TO_CODE[region_name]),
    model = factor(MODEL_TO_MODEL_DISPLAY_NAME[model], levels = MODELS)
  ) %>%
  group_by(
    configuration, month_start, region_code, model
  ) %>%
  summarise(
    flux = sum(flux)
  ) %>%
  mutate(
    season = factor(c(
      'DJF', 'DJF', 'MAM',
      'MAM', 'MAM', 'JJA',
      'JJA', 'JJA', 'SON',
      'SON', 'SON', 'DJF'
    )[month(month_start)], levels = c(
      'DJF', 'MAM', 'JJA', 'SON'
    )),
    month_region = factor(sprintf(
      '%s_%s',
      month_start,
      region_code
    ))
  )

fst::write_fst(mip_fluxes, 'intermediates/mip-fluxes.fst')
