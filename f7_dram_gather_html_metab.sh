#!/bin/bash

# Source and destination directories
SRC_DIR="/home/justind/oe75/csp1-3/data/dram/distill"
DEST_DIR_XLSX="/home/justind/oe75/csp1-3/data/dram/gather/metabolism"
DEST_DIR_HTML="/home/justind/oe75/csp1-3/data/dram/gather/html"

# Ensure destination directories exist
mkdir -p "$DEST_DIR_XLSX"
mkdir -p "$DEST_DIR_HTML"

# Function to process files
process_files() {
    local file_type="$1"
    local dest_dir="$2"

    # Using find to search for files recursively
    find "$SRC_DIR" -type f -name "$file_type" | while read -r file; do
        # Extracting parent directory name
        parent_dir=$(basename "$(dirname "$file")")

        # Forming new file name by prefixing parent directory name
        new_file_name="${parent_dir}_$(basename "$file")"

        # Copying the file to the destination directory with the new name
        cp "$file" "$dest_dir/$new_file_name"
    done
}

# Processing the files
process_files "metabolism_summary.xlsx" "$DEST_DIR_XLSX"
process_files "product.html" "$DEST_DIR_HTML"

