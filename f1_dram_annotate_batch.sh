#!/bin/bash

#SBATCH --job-name=dram_annotate_glab_2
#SBATCH --time=1-00:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=300G
#SBATCH --partition=short

#SBATCH --output=/home/justind/oe75/csp1-3/logs/dram/%x.%j.out
#SBATCH --error=/home/justind/oe75/csp1-3/logs/dram/%x.%j.err

source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/mamba.sh
source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/conda.sh

input_csv="/home/justind/oe75/csp1-3/data/vdb_dump/glab_2.csv"
out_dir="/home/justind/oe75/csp1-3/data/dram/annotate"

conda activate DRAM
while IFS= read -r line
do
    #Aviary samples
       #input_dir="/home/justind/oe75/csp1-3/data/aviary/aviary_${line}/recover/data"
       #child_dir_list=("maxbin2_bins" "metabat_bins_sspec" "metabat_bins_ssens" "rosella_bins" "output_prerecluster_bins" "output_recluster_bins")

    #Controls
       #input_dir="/home/justind/oe75/csp1-3/data/control_data/ncbi_dataset/data/${line}"
       #child_dir_list=("genbank")

    #GCA samples
       input_dir="/home/justind/oe75/csp1-3/data/gca_csp1_3_data/ncbi_dataset/data/${line}"
       child_dir_list=("genbank")
    
    #Greening Lab samples
       input_dir="/home/justind/oe75/csp1-3/data/greening_lab/${line}"
       child_dir_list=("g_lab")

    for child_dir in "${child_dir_list[@]}"
    do
        # Find directories that match the child_dir pattern
        for dir in $(find "$input_dir" -type d -name "$child_dir")
        do
            # Default file extension
            file_ext="fa"

            case "$child_dir" in
                "maxbin2_bins")
                    file_ext="fasta"
                    ;;
                "rosella_bins")
                    file_ext="fna"
                    ;;
                "genbank")
                    file_ext="fna"
                    ;; 
                *)
                    file_ext="fa"
                    ;;
            esac

            # Extract base directory name for prefix
            child_dir_basename=$(basename "$dir")
	    
            #mkdir "${out_dir}/${line}_${child_dir_basename}"
            # Run DRAM annotation
              DRAM.py annotate -i "${dir}/*.${file_ext}"  \
              -o  "${out_dir}/${line}_${child_dir_basename}" \
              --threads 48 --verbose
        done
    done
done < "$input_csv"

conda deactivate
