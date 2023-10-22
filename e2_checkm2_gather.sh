#!/bin/bash

# Define the input and output directories
input_dir="/home/justind/oe75/csp1-3/data/checkm2"
output_dir="/home/justind/oe75/csp1-3/data/checkm2"

# Output file path
output_file="${output_dir}/checkm2_gather.tsv"

# Iterate over all quality_report.tsv files in the input directory
find "$input_dir" -name "quality_report.tsv" -print0 | while IFS= read -r -d '' file; do
    # Get base name of the parent directory
    base_name=$(basename "${file%/*}")

    # Append base_name as an additional column, and concatenate base_name, underscore, and Name to form user_genome
    awk -v bn="$base_name" 'BEGIN{OFS=FS="\t"} {if(NR==1 && FNR==1){print $0,"base_name","user_genome"} else {print $0,bn,bn"_"$1}}' $file >> "$output_file.tmp"
done

# Filter out rows where the 15th column is "base_name"
#awk 'BEGIN{OFS=FS="\t"} {if($15!="base_name") print $0}' \
awk 'BEGIN{OFS=FS="\t"} {if(NR==1 || $15!="base_name") print $0}' \
"$output_file.tmp" > "$output_file"

# Clean up temporary file
rm "$output_file.tmp"

echo "Done. Output file: $output_file"

