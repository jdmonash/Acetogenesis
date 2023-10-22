#!/bin/bash

#SBATCH --job-name=megahit_assemble_paired_SRR13254584
#SBATCH --time=1-00:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=256G
#SBATCH --partition=short

#SBATCH --output=/home/justind/oe75/csp1-3/logs/aviary/assemble/%x.%j.out
#SBATCH --error=/home/justind/oe75/csp1-3/logs/aviary/assemble/%x.%j.err

#m -600 is 600GB. Make sure n m match cpus-per-task and mem

#Add these two lines to avoid CommandNotFoundError
#source /home/justind/mambaforge/etc/profile.d/conda.sh
#source /home/justind/mambaforge/etc/profile.d/mamba.sh

source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/mamba.sh
source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/conda.sh

#Not sure if this is needed....
conda activate base

#Min count is minimum number of k-mers
#This will filter out any k-mers appearing once which helps with the quality
#By removing sequences with errors.
#Also no need to specify memory with megahit as it will use 

megahit \
-1 /home/justind/oe75/csp1-3/data/sra_data/SRR13254584_1.fastq \
-2 /home/justind/oe75/csp1-3/data/sra_data/SRR13254584_2.fastq \
--out-dir /home/justind/oe75/csp1-3/data/aviary/aviary_SRR13254584 \
--min-count 2 \
--k-list 27,37,47,57,67,77,87,97,107,117,127 \
--num-cpu-threads 12

conda deactivate

