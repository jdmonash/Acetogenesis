#!/bin/bash

#This moves the control files into the same directory structure as the tests
#This makes the other scripts (GTDB, checkM2 etc) use consistent naming 
#Conventions (but instead of sample_binner_MAG it will be sample_genbank_assembly)

# Set your input directory here
input_dir="/home/justind/oe75/csp1-3/data/control_data/ncbi_dataset/data"

#Find all .fna files in input dir
find "$input_dir" -type f -name "*.fna" | while read fna_file; do
    # Get the directory containing the .fna file
    dir=$(dirname "$fna_file")

    # Create the genbank directory inside it
    mkdir -p "$dir/genbank"

    # Move the .fna file into the genbank directory
    mv "$fna_file" "$dir/genbank/"
done

