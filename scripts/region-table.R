source('scripts/partials/base.R')
source('scripts/partials/tables.R')

printf <- function(...) cat(sprintf(...))
paste_columns <- function(x) paste0(x, collapse = ' & ')
na_to_empty <- function(x) ifelse(is.na(x), '', x)

sink('figures/region-table.tex')
cat('\\begin{tabular}{l|l||l|l}\n')
printf('%s \\\\ \\hline\n', paste_columns(sprintf(
  '\\textbf{%s}',
  c('Code', 'Name', 'Code', 'Name')
)))
half_point <- ceiling(length(REGION_NAME_TO_CODE) / 2)
for (i in seq_len(half_point)) {
  printf(
    '%s & %s & %s & %s \\\\\n',
    REGION_NAME_TO_CODE[i],
    strsplit(names(REGION_NAME_TO_CODE)[i], ': ')[[1]][2],
    na_to_empty(REGION_NAME_TO_CODE[half_point + i]),
    na_to_empty(strsplit(names(REGION_NAME_TO_CODE)[half_point + i], ': ')[[1]][2])
  )
}
cat('\\end{tabular}\n')
sink(NULL)
