library(dplyr, warn.conflicts = FALSE)
library(lubridate, warn.conflicts = FALSE)
library(ncdf4)
library(ggplot2)

options(dplyr.summarise.inform = FALSE)

with_nc_file <- function(files, code, envir = parent.frame()) {
  for (nme in names(files)) {
    assign(
      nme,
      nc_open(files[[nme]]),
      envir = envir
    )
  }
  on.exit({
    for (nme in names(files)) {
      nc_close(get(nme, envir = envir))
      rm(list = nme, envir = envir)
    }
  })
  eval(substitute(code), envir = envir)
}

to_season <- function(x) {
  factor(c(
    'DJF', 'DJF', 'MAM',
    'MAM', 'MAM', 'JJA',
    'JJA', 'JJA', 'SON',
    'SON', 'SON', 'DJF'
  )[month(x)], levels = c(
    'DJF', 'MAM', 'JJA', 'SON'
  ))
}
