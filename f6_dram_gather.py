#!/usr/bin/env python

#SBATCH --job-name=dram_gather_python
#SBATCH --time=1-00:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=100G
#SBATCH --partition=short

#SBATCH --output=/home/justind/oe75/csp1-3/logs/dram/%x.%j.out
#SBATCH --error=/home/justind/oe75/csp1-3/logs/dram/%x.%j.err

import os
import pandas as pd

def gather_files(input_directory, input_filename, output_filename, output_directory, column_number):
    if not all([input_directory, input_filename, output_filename, output_directory, column_number]):
        print("Usage: gather_files(input_directory, input_filename, output_filename, output_directory, column_number)")
        return 1

    # Create the output directory if it doesn't exist
    os.makedirs(output_directory, exist_ok=True)

    final_output_path = os.path.join(output_directory, output_filename)

    # Remove the existing output file if it exists
    if os.path.exists(final_output_path):
        os.remove(final_output_path)

    # Initialize an empty DataFrame to hold the final result
    final_df = pd.DataFrame()

    # Loop through all subdirectories and find files with the specified name
    for dir_name in os.listdir(input_directory):
        dir_path = os.path.join(input_directory, dir_name)
        if os.path.isdir(dir_path):
            file_path = os.path.join(dir_path, input_filename)
            if os.path.exists(file_path):
                df = pd.read_csv(file_path, sep='\t')
                if column_number <= df.shape[1]:
                    new_column = df.iloc[:, column_number - 1].apply(lambda x: f"{dir_name}_{x}")
                    df.insert(0, 'user_genome', new_column)
                    final_df = pd.concat([final_df, df])

    # Write final DataFrame to the output file
    if not final_df.empty:
        final_df.to_csv(final_output_path, sep='\t', index=False)
        print(f"Processing complete. Final result saved in {final_output_path}")
    else:
        print("No data to write.")

#Example of how to run the function
#gather_files("input_dir", "input_file.tsv", "output_file.tsv", "output_dir", 2)

annotate_dir="/home/justind/oe75/csp1-3/data/dram/annotate"
distill_dir="/home/justind/oe75/csp1-3/data/dram/distill"
output_dir="/home/justind/oe75/csp1-3/data/dram/gather"

print("Gathering annotations")
gather_files(annotate_dir, "annotations.tsv", "dram_annotation_gather.tsv", output_dir, 2)
print("Gathering rrna")
gather_files(annotate_dir, "rrnas.tsv", "dram_rrna_gather.tsv", output_dir, 2)
print("Gathering trna")
gather_files(annotate_dir, "trnas.tsv", "dram_trna_gather.tsv", output_dir, 1)
print("Gathering genome stats")
gather_files(distill_dir, "genome_stats.tsv", "dram_gemome_stat_gather.tsv", output_dir, 1)
print("Gathering product")
gather_files(distill_dir, "product.tsv", "dram_product_gather.tsv", output_dir, 1)
