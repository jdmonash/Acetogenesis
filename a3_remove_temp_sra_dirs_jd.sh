#!/bin/bash
input="/home/justind/oe75/csp1-3/data/vdb_dump/remaining_sample_only.csv"
parent_dir="/home/justind/oe75/csp1-3/data/sra_data"

# read the file
while IFS= read -r line
do
  # combine parent directory with directory name from the file
  dir_to_delete="$parent_dir/$line"
  
  # check if the directory exists
  if [ -d "$dir_to_delete" ]; then
    # remove (recursive and force)
    rm -rf "$dir_to_delete"
    echo "Deleted directory $dir_to_delete"
  else
    echo "Directory $dir_to_delete does not exist"
  fi
done < "$input"

