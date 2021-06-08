# From Many to One: Consensus Inference in a MIP (SUPE-ANOVA)

This repository contains code to reproduce the results in the paper "From Many to One: Consensus Inference in a MIP". It implements the SUPE-ANOVA framework for the specific case of analysing the results of the [OCO-2 MIPv7](https://gml.noaa.gov/ccgg/OCO2/).

## Installation/setting up an environment

This repository uses the `make` tool to orchestrate the workflow and it is expected that it is run from a command line. It has been tested on macOS and ought to work on any UNIX-like system. The code in this repository is written in the [R programming language](https://www.r-project.org/) and any version of newer than 4.0 is expected to work.

The software dependencies are encoded using the [renv](https://rstudio.github.io/renv/articles/renv.html) package. If you have a new enough version of R and the renv package installed, you can run the following command from the repository root directory:

```
make bootstrap
```

This will use renv to install all the required packages.

## Required data

You need to create a folder named `data` in the root directory and add the following files to it:

- The file `L4-regionfluxes_2018-07-30.tar.gz`, available from the "Level 4 product download" section of the [OCO-2 MIPv7 website](https://gml.noaa.gov/ccgg/OCO2/). This tar file should be expanded into the data directory, resulting in a directory `data/ct/andy/OCO-2/l4_regionfluxes` which contains a series of NetCDF files.
- The OCO-2 MIPv7 region mask file, `oco2_regions_l4mip_v7.nc`, also available from the OCO-2 MIPv7 website. The link is currently on the homepage under "38 regions mask file (region definitions)". This file should also be placed in the `data` directory.

## Running the workflow

The workflow can be run simply with

```
make -j4
```

You can change the `-j4` to match how many cores are available in your system. If this command completes successfully, the `figures` folder will contain all the figures and tables from the paper.

