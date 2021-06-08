source('scripts/partials/base.R')
source('scripts/partials/display.R')
source('scripts/partials/tables.R')

library(tidyr)
library(patchwork)

REGION_CODE <- 'T05a'

mip_fluxes <- fst::read_fst('intermediates/mip-fluxes.fst')

unweighted_fluxes <- mip_fluxes %>%
  group_by(configuration, month_start, region_code) %>%
  summarise(
    flux_variance = NA, # var(flux) / n(),
    flux = mean(flux)
  )

predicted_fluxes <- readRDS('intermediates/fit.rds') %>%
  unnest(predicted_fluxes) %>%
  ungroup() %>%
  select(configuration, month_start, region_code, flux, flux_variance)

to_which <- function(x) factor(x, c('SUPE-ANOVA', 'Unweighted average'))

summary_df <- bind_rows(
  unweighted_fluxes %>% mutate(which = 'Unweighted average'),
  predicted_fluxes %>% mutate(which = 'SUPE-ANOVA')
) %>%
  filter(region_code == REGION_CODE) %>%
  mutate(which = to_which(which))

output_all <- ggplot(
    mapping = aes(month_start)
  ) +
    geom_line(
      data = mip_fluxes %>% filter(region_code == REGION_CODE),
      mapping = aes(y = flux, colour = model) #,
      # alpha = 0.8
    ) +
    geom_line(
      data = summary_df %>% filter(which == 'SUPE-ANOVA'),
      mapping = aes(y = flux, linetype = which),
      size = 0.8
    ) +
    geom_point(
      data = summary_df %>% filter(which == 'Unweighted average'),
      mapping = aes(y = flux, shape = which),
      size = 1
    ) +
    MODEL_SCALES$colour_darker +
    scale_linetype_manual(
      values = c('solid', 'dotted')
    ) +
    scale_shape_manual(
      values = 3
    ) +
    guides(
      colour = guide_legend(order = 1),
      linetype = guide_legend(order = 2),
      shape = guide_legend(order = 3)
    ) +
    labs(
      x = 'Month',
      y = 'Flux [PgC / month]',
      colour = NULL,
      linetype = NULL,
      shape = NULL
    ) +
    facet_grid(configuration ~ ., scales = 'free_y')

output_summary <- ggplot(
    mapping = aes(month_start)
  ) +
    geom_ribbon(
      data = summary_df %>% filter(which == 'SUPE-ANOVA'),
      mapping = aes(
        ymin = flux - 1.96 * sqrt(flux_variance),
        ymax = flux + 1.96 * sqrt(flux_variance),
        linetype = which
      ),
      fill = 'black',
      alpha = 0.2
    ) +
    geom_line(
      data = summary_df %>% filter(which == 'SUPE-ANOVA'),
      mapping = aes(y = flux, linetype = which),
      size = 0.8
    ) +
    geom_point(
      data = summary_df %>% filter(which == 'Unweighted average'),
      mapping = aes(y = flux, shape = which),
      size = 1
    ) +
    scale_linetype_manual(
      values = c('solid', 'dotted')
    ) +
    scale_shape_manual(
      values = 3
    ) +
    guides(
      linetype = guide_legend(order = 1),
      shape = guide_legend(order = 2)
    ) +
    labs(
      x = 'Month',
      y = 'Flux [PgC / month]',
      colour = NULL,
      linetype = NULL,
      shape = NULL
    ) +
    theme(legend.position = 'none') +
    facet_grid(configuration ~ ., scales = 'free_y')

output <- wrap_plots(
  output_all,
  output_summary,
  ncol = 1,
  guides = 'collect'
) +
  plot_annotation(
    tag_levels = 'a',
    tag_prefix = '(',
    tag_suffix = ')',
    title = sprintf('Fluxes for %s', REGION_CODE_TO_NAME[REGION_CODE]),
    theme = theme(plot.title = element_text(hjust = 0.5))
  )

ggsave(
  'figures/flux-regional.pdf',
  output,
  width = 17,
  height = 19,
  units = 'cm',
  bg = 'transparent'
)
