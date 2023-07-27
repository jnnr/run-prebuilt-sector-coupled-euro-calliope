# Workflow to run pre-built sector coupled euro-calliope model

This workflow automates the instructions given on https://energysystems-docs.netlify.app/tools/sector-coupled-euro-calliope-hands-on.html

First, create a conda environment with

    conda env create -f requirements_custom.yml

And activate it

    conda activate eurocalliope_2022_02_08

Then, download and unzip the pre-built models by running 

    snakemake --use-conda --profile default build/pre-built

Then, to build an run a model, e.g.

    snakemake --use-conda --profile default "build/eurospores/inputs/2016_res_3h.nc"

Or, in general:

    snakemake --use-conda --profile default "build/<resolution>/inputs/run_<year>_<model_resolution>.nc"

With these wildcard options:
resolution: eurospores|ehighways
year: 2010 - 2018
model_resolution: res_2h|res_3h|res_6h
