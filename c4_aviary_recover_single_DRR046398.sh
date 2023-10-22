#!/bin/bash

#SBATCH --job-name=aviary_recover_single_DRR046398
#SBATCH --time=1-00:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=200G
#SBATCH --partition=short

#SBATCH --output=/home/justind/oe75/csp1-3/logs/aviary/recover/%x.%j.out
#SBATCH --error=/home/justind/oe75/csp1-3/logs/aviary/recover/%x.%j.err

#Add these two lines to avoid CommandNotFoundError
#source /home/justind/mambaforge/etc/profile.d/conda.sh
#source /home/justind/mambaforge/etc/profile.d/mamba.sh

source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/mamba.sh
source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/conda.sh

#Note!! For jobs which failed for aviary assemble and had to be run with megahit
#the output was in the format of final.contigs.fa These have been copied so it is
#in a consistent format with the aviary output by going into those directories and running        
#mkdir data;cp final.contigs.fa ./data/final_contigs.fasta

conda activate aviary
aviary recover --assembly /home/justind/oe75/csp1-3/data/aviary/aviary_DRR046398/data/final_contigs.fasta \
-1 /home/justind/oe75/csp1-3/data/sra_data/DRR046398.fastq \
-o /home/justind/oe75/csp1-3/data/aviary/aviary_DRR046398/recover \
-n 8 \
--gtdb_path /home/justind/oe75/Database/GTDB-tk/release214
conda deactivate
