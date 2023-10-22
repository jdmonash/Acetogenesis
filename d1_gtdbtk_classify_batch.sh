#!/bin/bash

#SBATCH --job-name=gtdbtk_classify_batch_g_lab
#SBATCH --time=1-00:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=100G
#SBATCH --partition=short

#SBATCH --output=/home/justind/oe75/csp1-3/logs/gtdbtk/%x.%j.out
#SBATCH --error=/home/justind/oe75/csp1-3/logs/gtdbtk/%x.%j.err

source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/mamba.sh
source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/conda.sh


input_csv="/home/justind/oe75/csp1-3/data/vdb_dump/glab_2.csv"
out_dir="/home/justind/oe75/csp1-3/data/gtdbtk/"

conda activate gtdbtk
while IFS= read -r line
do

#The directory structure for controls, GCA and Greening lab samples is not ideal, but this is based on the
# directory structure which Aviary exports to
# In hindsight it possibly would have been preferable writing a script to move all the Aviary MAGs to the one folder
# rather than having to have the below code to pick out particular files.

#Controls
   #input_dir="/home/justind/oe75/csp1-3/data/control_data/ncbi_dataset/data/${line}"
   #child_dir_list=("genbank")

#GCA samples 
   #input_dir="/home/justind/oe75/csp1-3/data/gca_csp1_3_data/ncbi_dataset/data/${line}"
   #child_dir_list=("genbank")

#Greening Lab samples
    input_dir="/home/justind/oe75/csp1-3/data/greening_lab/${line}"
    child_dir_list=("g_lab")

#Tests
   #input_dir="/home/justind/oe75/csp1-3/data/aviary/aviary_${line}/recover/data"
   #child_dir_list=("maxbin2_bins" "metabat_bins_sspec" "metabat_bins_ssens" "rosella_bins" "output_prerecluster_bins" "output_recluster_bins")
    
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

            # Run gtdbtk
            gtdbtk classify_wf --cpus 48 --force \
            --genome_dir "$dir" \
            --out_dir ${out_dir}/${line}_${child_dir_basename} \
            -x $file_ext \
            --prefix "${line}_${child_dir_basename}" \
            --mash_db /home/justind/oe75/Database/GTDB-tk/release214/gtdb_ref_sketch.msh
        done
    done
done < "$input_csv"

conda deactivate
