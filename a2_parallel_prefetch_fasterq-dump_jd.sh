#!/bin/bash

#SBATCH --job-name=jd_sra_batch_test_sample
#SBATCH --time=1-00:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=12 
#SBATCH --mem=100G
#SBATCH --partition=short 

#SBATCH --output=/home/justind/oe75/csp1-3/logs/sra/%x.%j.out
#SBATCH --error=/home/justind/oe75/csp1-3/logs/sra/%x.%j.err

out_dir=/home/justind/oe75/csp1-3/data/sra_data
input_csv="/home/justind/oe75/csp1-3/data/vdb_dump/FINAL_35.csv"

# Check if the directory exists
if [ ! -d "$out_dir" ]; then
    #Then create the directory
    mkdir -p "$out_dir"
fi

export PATH=/home/justind/oe75/justind/CSP1-3/tools/sratoolkit.3.0.1-ubuntu64/bin:$PATH

cd $out_dir
#Prefetch the data
parallel --verbose -j 12 prefetch --verbose {} ::: $(cut -f1 $input_csv)
wait
#Get the data
parallel --verbose -j 12 fasterq-dump --verbose {} ::: $(cut -f1 $input_csv)
wait
exit
