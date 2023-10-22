#!/bin/bash
#SBATCH --job-name=dram_distill_batch
#SBATCH --time=1-00:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=100G
#SBATCH --cpus-per-task=48
#SBATCH --partition=short


#SBATCH --output=/home/justind/oe75/csp1-3/logs/dram/%x.%j.out
#SBATCH --error=/home/justind/oe75/csp1-3/logs/dram/%x.%j.err

source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/mamba.sh
source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/conda.sh

#Path to output directories
out_dir="/home/justind/oe75/csp1-3/data/dram/distill"


conda activate DRAM
#Run on all - don't really need to direct to specific directories
#As it's doesn't require many resources.
 
for dir in /home/justind/oe75/csp1-3/data/dram/annotate/*; do

#Get basename of directory
base_name=$(basename "$dir")

#Output to a basename of directory
output_dir="${out_dir}/${base_name}"

#Check if directory, so it doesn't try to run it on other files
    if [ -d "$dir" ]; then
        cd "$dir"
        echo checking "${dir}"
        # Check if rrnas.tsv exists in the directory, if not don't run --rrna_path
        if [ -f rrnas.tsv ]; then
            DRAM.py distill -i annotations.tsv -o "${output_dir}" --trna_path trnas.tsv --rrna_path rrnas.tsv
            echo distillin in "${output_dir}"
        elif [ -f annotations.tsv ]; then
            echo distillin in "${output_dir}"
            DRAM.py distill -i annotations.tsv -o "${output_dir}" --trna_path trnas.tsv
        fi
        cd ..
    fi
done

conda deactivate
