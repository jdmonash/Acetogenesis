#!/bin/bash

#SBATCH --job-name=dram_annotate_single_ERR6466192
#SBATCH --time=1-00:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=100G
#SBATCH --partition=short

#SBATCH --output=/home/justind/oe75/csp1-3/logs/dram/%x.%j.out
#SBATCH --error=/home/justind/oe75/csp1-3/logs/dram/%x.%j.err

source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/mamba.sh
source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/conda.sh

conda activate DRAM
sample="ERR6466192"

# Specify the exact file path
input_file="/home/justind/oe75/csp1-3/data/aviary/aviary_ERR6466192/recover/data/semibin_bins/output_recluster_bins/bin.32.fa"

#
output_dir_basename="output_recluster_binscd "

DRAM.py annotate -i "${input_file}"  \
-o  "/home/justind/oe75/csp1-3/data/dram/annotate/${sample}_${output_dir_basename}" \
--threads 24 --verbose

conda deactivate

