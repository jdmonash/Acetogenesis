#!/bin/bash

output_file="/home/justind/oe75/csp1-3/data/gtdbtk/gtdb_gather.tsv"

# Delete the output file if it exists
if [ -f "$output_file" ]; then
    rm "$output_file"
fi

#Write header value to file.
header_written=false

# Find all .summary.tsv files
find "/home/justind/oe75/csp1-3/data/gtdbtk/" -type f -name "*.summary.tsv" |
while IFS= read -r file_path; do
    # Get the base name of the file
    base_name=$(basename "$file_path")

    # Remove the specific extensions from the base name
    base_name=${base_name//.bac120.summary.tsv/}
    base_name=${base_name//.ar53.summary.tsv/}

    # Check if header is already written
    if ! $header_written; then
        # Add header row to the output file
        head -n 1 "$file_path" | awk -v basename="base_name" 'BEGIN{FS=OFS="\t"} {print $0, basename}' >> "$output_file"
        header_written=true
    fi

    # Process each row except for header, update the user_genome column, and append to output file
    awk -v basename="$base_name" 'BEGIN{FS=OFS="\t"} NR>1 { $1 = basename "_" $1; print $0, basename }' "$file_path" >> "$output_file"
done

echo "Done. Output file: $output_file"

