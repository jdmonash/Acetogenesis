#!/bin/bash

# Path to the CSV file
csv_list="/home/justind/oe75/csp1-3/data/vdb_dump/gl_gca_accession.csv"

# Output directory
output_dir="/home/justind/oe75/csp1-3/data/gca_csp1_3_data"

# Loop through each line in the CSV file
while IFS= read -r line; do
  # Download the ZIP file
  datasets download genome accession "${line}" --filename "${line}".zip
  
  # Unzip the ZIP file to the specified directory, force overwriting existing files
  unzip -o "${line}".zip -d "${output_dir}"
  
  # Remove the ZIP file
  rm "${line}".zip
done < "${csv_list}"

