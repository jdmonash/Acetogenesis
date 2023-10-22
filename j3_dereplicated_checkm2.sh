#!/bin/bash

#SBATCH --job-name=drep_checkm2_post
#SBATCH --time=1-00:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=200G
##SBATCH --partition=short

#SBATCH --output=/home/justind/oe75/csp1-3/logs/drep/%x.%j.out
#SBATCH --error=/home/justind/oe75/csp1-3/logs/drep/%x.%j.err

source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/mamba.sh
source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/conda.sh

mamba activate checkm2

dereplicated_dir=/home/justind/oe75/csp1-3/data/drep/everything_except_controls/dereplicated_genomes
checkm2_out_dir=/home/justind/oe75/csp1-3/results/checkm2_post_drep

function create_directories () {
    mkdir -p "$checkm2_out_dir"
}

function run_checkm2 () {
    checkm2 predict --threads 16 --input "$dereplicated_dir" --output-directory "$checkm2_out_dir" -x fa
}

create_directories 
run_checkm2 


mamba deactivate
