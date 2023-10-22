#!/bin/bash

#SBATCH --job-name=diamondp_batch_aceto
#SBATCH --time=1-00:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=200G
#SBATCH --partition=short

#SBATCH --output=/home/justind/oe75/csp1-3/logs/diamond_blastp/%x.%j.out
#SBATCH --error=/home/justind/oe75/csp1-3/logs/diamond_blastp/%x.%j.err

source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/mamba.sh
source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/conda.sh

#out_dir="/home/justind/oe75/csp1-3/data/diamond_blastp"
sample=acetogens
diamondp_out_base="/home/justind/oe75/csp1-3/data/aceto_diamond_blastp"
out_dir="$diamondp_out_base"/"$sample"

#Comment out whichever particular directory is not required
proteome_dir="/home/justind/oe75/csp1-3/data/checkm2"
#Control directory with Greening Lab test proteins
#proteome_dir="/home/justind/oe75/csp1-3/data/gl_control_data_protein"
input_csv="/home/justind/oe75/csp1-3/data/vdb_dump/everything.csv"
#input_csv="/home/justind/oe75/csp1-3/data/vdb_dump/gl_test_2.csv"
#diamond_db="/home/justind/oe75/Database/All_in_one/Funcgenes_51_Dec2021.dmnd"
diamond_db="/home/justind/oe75/csp1-3/data/acetogenesis_db/acetogenesis.dmnd"

conda activate checkm2

# Set up
function create_directories() {
    mkdir -p "$diamondp_out_base"
    mkdir -p "$out_dir"
    cd "$out_dir" && mkdir -p raw prefiltered filtered summary
}

function run_diamondp() {
    while read -r line; do
        for protein_file_dir in "${proteome_dir}/${line}"*/protein_files; do
            prefix=$(basename "$(dirname "$protein_file_dir")") # Parent directory name of protein_files directory

            for mag in "$protein_file_dir"/*.faa; do
                base="$(echo ${mag} | sed 's|.*/||' | sed 's/.faa//')"
                #base="$(basename -- $mag | sed 's/.fna.faa//')"
                diamond blastp --db $diamond_db --query $mag --out $out_dir/${prefix}_"$base"_acetogenesis.txt \
                --max-hsps 1 --max-target-seqs 1 --threads 48 --outfmt 6 qtitle stitle pident slen qstart qend sstart send evalue bitscore qcovhsp scovhsp length full_qseq
            done
            wait
        done

        cd $out_dir
        for file in *acetogenesis.txt
        do
            awk '{print $0,"\t",FILENAME}' $file >> summary/acetogenesis.txt
        done
        wait
    done < "$input_csv"

}

# Prefilter based on either query or subject coverager >= 80%, summarise prefiltered output
function perform_prefilter () {
    cd $out_dir
    for hit in *acetogenesis.txt
    do
        awk -F '\t' '$11 >= 80 || $12 >= 80 {print $0}' $hit > prefiltered/${hit/.txt/_prefiltered.txt}
    done
    wait
    for hit in prefiltered/*prefiltered.txt
    do
        awk '{print $0,"\t",FILENAME}' $hit >> summary/acetogenesis_prefiltered.txt
    done
    wait
}

function organize_output () {
    cd $out_dir
    mv *acetogenesis.txt $out_dir/raw
    cd summary
    awk -F "\t" '{print $1"\t"$2"\t"$15}' acetogenesis_prefiltered.txt > acetogenesis_prefiltered.summary.tsv
    sed -i 's/_acetogenesis_prefiltered.txt//' acetogenesis_prefiltered.summary.tsv
    sed -i 's/prefiltered\///' acetogenesis_prefiltered.summary.tsv
}

create_directories
run_diamondp
perform_prefilter
organize_output

conda deactivate
