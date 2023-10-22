#!/bin/bash

#SBATCH --job-name=drep_all
#SBATCH --time=1-00:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=256G
#SBATCH --partition=short

#SBATCH --output=/home/justind/oe75/csp1-3/logs/drep/%x.%j.out
#SBATCH --error=/home/justind/oe75/csp1-3/logs/drep/%x.%j.err

source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/mamba.sh
source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/conda.sh

mamba activate checkm2

merged_dir="/home/justind/oe75/csp1-3/data/mag_copies/all_except_controls"
checkm2_out_dir="/home/justind/oe75/csp1-3/results/checkm2_pre_drep"
drep_out_dir="/home/justind/oe75/csp1-3/data/drep"

function create_directories () {
    mkdir -p "$checkm2_out_dir" "$drep_out_dir"
}

function run_checkm2 () {
    time checkm2 predict --threads 48 --input "$merged_dir" --output-directory "$checkm2_out_dir" -x fa
}

create_directories 
run_checkm2 

#Installed drep in the Checkm2 environment by accident, will leave there for now.
#mamba deactivate
#mamba activate drep

function convert () {
    cd "$checkm2_out_dir"
    /home/justind/oe75/csp1-3/scripts/j2_convert_checkm2_gn.py ./quality_report.tsv ./quality_report.csv
}

function run_drep () {
    time dRep dereplicate -g "$merged_dir"/*.fa -p 48 -comp 50 -con 10 -sa 0.99 -nc 0.3 --genomeInfo "$checkm2_out_dir"/quality_report.csv "$drep_out_dir"
}

convert
run_drep

mamba deactivate
