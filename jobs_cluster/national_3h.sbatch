#!/bin/sh

#SBATCH --job-name="sector-coupled-euro-calliope-national-3h"
#SBATCH --partition=compute
#SBATCH --time=02:30:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=64G
#SBATCH --mail-type=END
#SBATCH --account=research-tpm-ess 

cd ..;
srun snakemake --use-conda --profile default "build/national/outputs/2016_res_3h.nc"
