#!/bin/sh

#SBATCH --job-name="sector-coupled-euro-calliope-eurospores-3h"
#SBATCH --partition=compute
#SBATCH --time=04:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=96G
#SBATCH --mail-type=END
#SBATCH --account=research-tpm-ess 

cd ..;
conda activate eurocalliope_2022_02_08;
srun snakemake --use-conda --profile default "build/eurospores/outputs/2016_res_3h.nc"
