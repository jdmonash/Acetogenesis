#!/bin/bash

#SBATCH --job-name=diamondp_batch_glab
#SBATCH --time=1-00:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=300G
#SBATCH --partition=short

#SBATCH --output=/home/justind/oe75/csp1-3/logs/diamond_blastp/%x.%j.out
#SBATCH --error=/home/justind/oe75/csp1-3/logs/diamond_blastp/%x.%j.err

source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/mamba.sh
source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/conda.sh

out_dir="/home/justind/oe75/csp1-3/data/diamond_blastp"

#Comment out whichever particular directory is not required
proteome_dir="/home/justind/oe75/csp1-3/data/checkm2"

input_csv="/home/justind/oe75/csp1-3/data/vdb_dump/everything.csv"
diamond_db="/home/justind/oe75/Database/All_in_one/Funcgenes_51_Dec2021.dmnd"

conda activate checkm2

# Set up
function create_directories() {
    cd "$out_dir" && mkdir -p raw prefiltered filtered summary
}

function run_diamondp() {
    while read -r line; do
        for protein_file_dir in "${proteome_dir}/${line}"*/protein_files; do
            prefix=$(basename "$(dirname "$protein_file_dir")") # Parent directory name of protein_files directory

            for mag in "$protein_file_dir"/*.faa; do
                base="$(echo ${mag} | sed 's|.*/||' | sed 's/.faa//')"
                diamond blastp --db $diamond_db --query $mag --out $out_dir/${prefix}_"${base}"_Funcgenes_51.txt --max-hsps 1 --max-target-seqs 1 --threads 48 --outfmt 6 qtitle stitle pident slen qstart qend sstart send evalue bitscore qcovhsp scovhsp length full_qseq
            done
            wait
        done

        cd $out_dir
        for file in *Funcgenes_51.txt; do
            awk '{print $0,"\t",FILENAME}' $file >> summary/Funcgenes_51.txt
        done
        wait
    done < "$input_csv"

}

# 3 - Prefilter based on either query or subject coverager >= 80%, summarise prefiltered output
function perform_prefilter () {
    cd $out_dir
    for hit in *_Funcgenes_51.txt
    do
        awk -F '\t' '$11 >= 80 || $12 >= 80 {print $0}' $hit > prefiltered/${hit/.txt/_prefiltered.txt}
    done
    wait
    for hit in prefiltered/*prefiltered.txt
    do
        awk '{print $0,"\t",FILENAME}' $hit >> summary/Funcgenes_51_prefiltered.txt
    done
    wait
}

# 
function perform_filter () {
    cd $out_dir/prefiltered
    for hit in *_Funcgenes_51_prefiltered.txt
    do
        # Sulfur cycle
        grep "DsrA-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "FCC-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "Sqr-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "Sor-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "AsrA-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "SoxB-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        # Carbon fixation
        grep "RbcL-" $hit | awk -F '\t' '{if ($3 >= 60) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "AcsB-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "CooS-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "AclB-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "Mcr-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "HbsC-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "HbsT-" $hit | awk -F '\t' '{if ($3 >= 75) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        # Nitrogen cycle
        grep "AmoA-" $hit | awk -F '\t' '{if ($3 >= 60) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "NxrA-" $hit | awk -F '\t' '{if ($3 >= 60) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "NarG-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "NapA-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "NirS-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "NirK-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "NrfA-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "NosZ-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "HzsA-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "NifH-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "NorB-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "Nod-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        # Trace gas metabolism
        grep "CoxL-" $hit | awk -F '\t' '{if ($3 >= 60) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "FeFe-" $hit | awk -F '\t' '{if ($3 >= 60) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "\[Fe]" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "NiFe-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' | awk -F '\t' '{if (!/Group\ 4/) print $0; else if ($3 >= 60) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "PmoA-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "MmoA-" $hit | awk -F '\t' '{if ($3 >= 60) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "McrA-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "IsoA-" $hit | awk -F '\t' '{if ($3 >= 70) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        # Phototrophy
        grep "RHO-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "PsaA-" $hit | awk -F '\t' '{if ($3 >= 80) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "PsbA-" $hit | awk -F '\t' '{if ($3 >= 70) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        # Alternative_e_acceptor
        grep "ArsC-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "MtrB-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "OmcB-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "RdhA-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "YgfK-" $hit | awk -F '\t' '{if ($3 >= 70) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        # Alternative_e_donor
        grep "ARO-" $hit | awk -F '\t' '{if ($3 >= 70) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "Cyc2" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "FdhA-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        # Respiration
        grep "SdhA_FrdA-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "AtpA-" $hit | awk -F '\t' '{if ($3 >= 70) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "CcoN-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "CoxA-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "CydA-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "CyoA-" $hit | awk -F '\t' '{if ($3 >= 50) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
        grep "NuoF-" $hit | awk -F '\t' '{if ($3 >= 60) print $0}' >> "$out_dir/filtered/${hit/_prefiltered.txt/_filtered.txt}" || true 
    done
}

function concatenate_output () {
    cd $out_dir
    for hit in filtered/*_filtered.txt
    do
        awk '{print $0,"\t",FILENAME}' $hit >> summary/Funcgenes_51_filtered.txt
    done
}

function organize_output () {
    cd $out_dir
    #Leave in main directory for testing
    mv *Funcgenes_51.txt $out_dir/raw
    cd summary
    awk -F "\t" '{print $1"\t"$2"\t"$15}' Funcgenes_51_filtered.txt > Funcgenes_51_filtered.summary.tsv
    sed -i 's/_Funcgenes_51_filtered.txt//' Funcgenes_51_filtered.summary.tsv
    sed -i 's/filtered\///' Funcgenes_51_filtered.summary.tsv
}

create_directories 
run_diamondp 
perform_prefilter
perform_filter
concatenate_output
organize_output

conda deactivate
