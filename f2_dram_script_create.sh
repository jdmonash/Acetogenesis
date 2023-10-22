#!/bin/bash

source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/mamba.sh
source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/conda.sh

input_csv="/home/justind/oe75/csp1-3/data/vdb_dump/gdbtk_class_8_of_10.csv"
out_dir="/home/justind/oe75/csp1-3/data/dram/annotate"

while IFS= read -r line; do

    # Construct the script content
    script_content="#!/bin/bash

#SBATCH --job-name=dram_annotate_8of10_${line}
#SBATCH --time=7-00:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=250G
# --partition=short

#SBATCH --output=/home/justind/oe75/csp1-3/logs/dram/%x.%j.out
#SBATCH --error=/home/justind/oe75/csp1-3/logs/dram/%x.%j.err

source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/mamba.sh
source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/conda.sh

conda activate DRAM

input_dir=\"/home/justind/oe75/csp1-3/data/aviary/aviary_${line}/recover/data\"
child_dir_list=(\"maxbin2_bins\" \"metabat_bins_sspec\" \"metabat_bins_ssens\" \"rosella_bins\" \"output_prerecluster_bins\" \"output_recluster_bins\")

#Controls
#input_dir=\"/home/justind/oe75/csp1-3/data/control_data/ncbi_dataset/data/${line}\"
#child_dir_list=(\"genbank\")


for child_dir in \"\${child_dir_list[@]}\"
do
    for dir in \$(find \"\$input_dir\" -type d -name \"\$child_dir\")
    do
        file_ext=\"fa\"

        case \"\$child_dir\" in
            \"maxbin2_bins\")
                file_ext=\"fasta\"
                ;;
            \"rosella_bins\")
                file_ext=\"fna\"
                ;;
            \"genbank\")
                file_ext=\"fna\"
                ;;
            *)
                file_ext=\"fa\"
                ;;
        esac

        child_dir_basename=\$(basename \"\$dir\")

        DRAM.py annotate -i \"\${dir}/*.\${file_ext}\"  \\
        -o  \"${out_dir}/${line}_\${child_dir_basename}\" \\
        --threads 24 --verbose
    done
done

conda deactivate"

    # Save the content to a new script file
    echo "$script_content" > "f3_dram_annotate_8of10_${line}.sh"

    # Make the new script executable
    chmod +x "f3_dram_annotate_8of10_${line}.sh"

done < "$input_csv"

