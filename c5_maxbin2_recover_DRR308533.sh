#!/bin/bash

#SBATCH --job-name=maxbin2_recover_single_DRR308533
#SBATCH --time=7-00:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=200G
#--partition=short

#SBATCH --output=/home/justind/oe75/csp1-3/logs/aviary/recover/%x.%j.out
#SBATCH --error=/home/justind/oe75/csp1-3/logs/aviary/recover/%x.%j.err

#Add these two lines to avoid CommandNotFoundError
#source /home/justind/mambaforge/etc/profile.d/conda.sh
#source /home/justind/mambaforge/etc/profile.d/mamba.sh

source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/mamba.sh
source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/conda.sh

conda activate base
run_MaxBin.pl \
-contig /home/justind/oe75/csp1-3/data/aviary/aviary_DRR308533/data/final_contigs.fasta \
-reads /home/justind/oe75/csp1-3/data/sra_data/DRR308533.fastq \
-out /home/justind/oe75/csp1-3/data/aviary/aviary_DRR308533/recover
conda deactivate
