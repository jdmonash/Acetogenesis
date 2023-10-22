#!/bin/bash
#SBATCH --job-name=phylophlan_dereplicated
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
#SBATCH --time=1-00:00:00
#SBATCH --mem=300G
#SBATCH --partition=short

#SBATCH --output=/home/justind/oe75/csp1-3/logs/phylophlan/%x.%j.out
#SBATCH --error=/home/justind/oe75/csp1-3/logs/phylophlan/%x.%j.err

source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/mamba.sh
source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/conda.sh

# Activate environment
mamba activate phylophlan

# Define paths
IN_DIR="/home/justind/oe75/csp1-3/data/drep/everything_except_controls/dereplicated_genomes"
OUT_DIR="/home/justind/oe75/csp1-3/results/phylophlan"
CONFIG_PATH="/home/justind/oe75/csp1-3/tools/phylophlan-3.0.3/supermatrix_aa.cfg"

# Function to create necessary directories
create_directories() {
    mkdir -p "$OUT_DIR"
}

# Function to run phylophlan
run_phylophlan() {
    phylophlan \
        --input_folder "$IN_DIR" \
        --output_folder "$OUT_DIR" \
        --nproc 48 \
        --diversity medium \
        -d phylophlan \
        -f "$CONFIG_PATH" \
        -i dereplicated \
        --genome_extension fa
}

# Execute functions 
create_directories
run_phylophlan

# Deactivate environment
mamba deactivate
