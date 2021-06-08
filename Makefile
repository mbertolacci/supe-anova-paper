DATA_DIR = data
INTERMEDIATES_DIR = intermediates
SCRIPTS_DIR = scripts
FIGURES_DIR = figures

BASE_PARTIAL = $(SCRIPTS_DIR)/partials/base.R
DISPLAY_PARTIAL = $(SCRIPTS_DIR)/partials/display.R
TABLES_PARTIAL = $(SCRIPTS_DIR)/partials/tables.R

FIGURES = $(FIGURES_DIR)/region-map.pdf \
	$(FIGURES_DIR)/region-table.tex \
	$(FIGURES_DIR)/clustering-map.pdf \
	$(FIGURES_DIR)/climatological-weights.pdf \
	$(FIGURES_DIR)/flux-aggregates-bivariate.pdf \
	$(FIGURES_DIR)/flux-regional.pdf \
	$(FIGURES_DIR)/flux-land-ocean-ln.pdf \
	$(FIGURES_DIR)/qqplots.pdf

$(shell mkdir -p $(INTERMEDIATES_DIR) $(FIGURES_DIR))

all: $(FIGURES)

## Bootstrap

bootstrap:
	Rscript -e "renv::restore()"

## Figures

$(FIGURES_DIR)/region-table.tex: $(SCRIPTS_DIR)/region-table.R $(BASE_PARTIAL) $(TABLES_PARTIAL)
	Rscript $<

$(FIGURES_DIR)/region-map.pdf: $(SCRIPTS_DIR)/region-map.R $(INTERMEDIATES_DIR)/region-centroids.rds $(INTERMEDIATES_DIR)/region-sf.rds $(BASE_PARTIAL) $(DISPLAY_PARTIAL) $(TABLES_PARTIAL)
	Rscript $<

$(FIGURES_DIR)/clustering-map.pdf: $(SCRIPTS_DIR)/clustering-map.R $(INTERMEDIATES_DIR)/clustering.rds $(INTERMEDIATES_DIR)/region-sf.rds $(BASE_PARTIAL) $(DISPLAY_PARTIAL) $(TABLES_PARTIAL)
	Rscript $<

$(FIGURES_DIR)/climatological-weights.pdf: $(SCRIPTS_DIR)/climatological-weights.R $(INTERMEDIATES_DIR)/fit.rds $(BASE_PARTIAL) $(DISPLAY_PARTIAL) $(TABLES_PARTIAL)
	Rscript $<

$(FIGURES_DIR)/flux-land-ocean-ln.pdf: $(SCRIPTS_DIR)/flux-land-ocean-ln.R $(INTERMEDIATES_DIR)/mip-fluxes.fst $(BASE_PARTIAL) $(DISPLAY_PARTIAL) $(TABLES_PARTIAL)
	Rscript $<

$(FIGURES_DIR)/flux-aggregates-bivariate.pdf: $(SCRIPTS_DIR)/flux-aggregates-bivariate.R $(INTERMEDIATES_DIR)/fit.rds $(INTERMEDIATES_DIR)/mip-fluxes.fst $(BASE_PARTIAL) $(DISPLAY_PARTIAL) $(TABLES_PARTIAL)
	Rscript $<

$(FIGURES_DIR)/flux-regional.pdf: $(SCRIPTS_DIR)/flux-regional.R $(INTERMEDIATES_DIR)/fit.rds $(INTERMEDIATES_DIR)/mip-fluxes.fst $(BASE_PARTIAL) $(DISPLAY_PARTIAL) $(TABLES_PARTIAL)
	Rscript $<

$(FIGURES_DIR)/qqplots.pdf: $(SCRIPTS_DIR)/qqplots.R $(INTERMEDIATES_DIR)/fit.rds $(BASE_PARTIAL) $(DISPLAY_PARTIAL) $(TABLES_PARTIAL)
	Rscript $<

## Intermediates

$(INTERMEDIATES_DIR)/fit.rds: $(SCRIPTS_DIR)/fit.R $(INTERMEDIATES_DIR)/clustering.rds $(INTERMEDIATES_DIR)/mip-fluxes.fst $(BASE_PARTIAL) $(TABLES_PARTIAL)
	Rscript $<

$(INTERMEDIATES_DIR)/region-centroids.rds: $(SCRIPTS_DIR)/region-centroids.R $(INTERMEDIATES_DIR)/region-sf.rds $(BASE_PARTIAL) $(TABLES_PARTIAL)
	Rscript $<

$(INTERMEDIATES_DIR)/region-sf.rds: $(SCRIPTS_DIR)/region-sf.R $(BASE_PARTIAL) $(TABLES_PARTIAL)
	Rscript $<

$(INTERMEDIATES_DIR)/clustering.rds: $(SCRIPTS_DIR)/clustering.R $(INTERMEDIATES_DIR)/mip-fluxes.fst $(BASE_PARTIAL) $(TABLES_PARTIAL)
	Rscript $<

$(INTERMEDIATES_DIR)/mip-fluxes.fst: $(SCRIPTS_DIR)/mip-fluxes.R $(INTERMEDIATES_DIR)/mip-fluxes-raw.fst $(BASE_PARTIAL) $(TABLES_PARTIAL)
	Rscript $<

$(INTERMEDIATES_DIR)/mip-fluxes-raw.fst: $(SCRIPTS_DIR)/mip-fluxes-raw.R $(BASE_PARTIAL) $(TABLES_PARTIAL)
	Rscript $<
