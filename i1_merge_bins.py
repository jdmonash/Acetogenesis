#!/usr/bin/env python
import os
import shutil
import pandas as pd
import re

#The first part of this script will filter the merged_data file for whichever specimens are entered in the filter_list
#As the different binning algorithms all have slightly different directory paths and fasta file formats
#An additional column is added to the filtered merge data with the file path for each genome 
#The second part of the script will read through the csv and copy the files to the directories based on the classifications (CSP1-3)
#Potential enhancement: filter by specimen?


# Initialize variables
result_dir = "/home/justind/oe75/csp1-3/results/"
#This is the output from the output of the 
merged_data_csv = "genome_list_for_drep.csv"
filter_list = ["Everything"]
#This is for High and Medium Quality, drep with 10% contamination.
#filter_list = ["High-quality CSP1-3","Highly contaminated CSP1-3"]
#This is for all CSP1-3, drep with 20% contamination.
#filter_list = ["Medium-quality CSP1-3","High-quality CSP1-3","Highly contaminated CSP1-3","Low-quality CSP1-3"]

#This is to exclude controls if needed
exclude_list=[
"GCA_029715615.1_genbank_GCA_029715615.1_ASM2971561v1_genomic",
"GCA_000247605.1_genbank_GCA_000247605.1_ASM24760v1_genomic",
"GCA_001267435.1_genbank_GCA_001267435.1_ASM126743v1_genomic",
"GCA_000179635.2_genbank_GCA_000179635.2_ASM17963v2_genomic",
"GCA_000184705.1_genbank_GCA_000184705.1_ASM18470v1_genomic",
"GCA_001267405.1_genbank_GCA_001267405.1_ASM126740v1_genomic",
"GCA_900100695.1_genbank_GCA_900100695.1_IMG-taxon_2602042031_annotated_assembly_genomic",
"GCA_900109655.1_genbank_GCA_900109655.1_IMG-taxon_2651870358_annotated_assembly_genomic",
"GCA_016213825.1_genbank_GCA_016213825.1_ASM1621382v1_genomic",
"GCA_000621285.1_genbank_GCA_000621285.1_ASM62128v1_genomic",
"GCA_001729945.1_genbank_GCA_001729945.1_ASM172994v1_genomic"]

# Read CSV
csv_path = result_dir + merged_data_csv
df = pd.read_csv(csv_path)

# Filter the DataFrame based on the 'Status' column - comment this out if not filtering anything
#Create a copy to avoid the SeetingWithCopyWarning
#df_filtered = df[df['Status'].isin(filter_list)].copy()

#Uncomment this if no filtering done
df_filtered = df

#Then also exclude controls if needed
df_filtered = df_filtered[~df_filtered['user_genome'].isin(exclude_list)].copy()

# Function to calculate 'genome_path' and add to 
def add_genome_path(user_genome):
    if 'GCA' in user_genome:
        dir_prefix = "/home/justind/oe75/csp1-3/data/control_data/ncbi_dataset/data/"
        file_type = ".fna"
        return dir_prefix + re.sub("_genbank_", "/genbank/", user_genome) + file_type

    if 'g_lab' in user_genome:
        dir_prefix = "/home/justind/oe75/csp1-3/data/greening_lab/"
        file_type = ".fa"
        # Capture the pattern 'xxx.bin.yyy' before '_g_lab'
        match = re.search(r'(.+\.bin\..+)_g_lab', user_genome)
        if match:
            identifier = match.group(1)
            return f"{dir_prefix}{identifier}/g_lab/{identifier}{file_type}"

    else:
        dir_prefix = "/home/justind/oe75/csp1-3/data/aviary/aviary_"
        suffixes = {
            "_maxbin2_bins_": "/recover/data/maxbin2_bins/",
            "_metabat_bins_ssens_": "/recover/data/metabat_bins_ssens/",
            "_metabat_bins_sspec_": "/recover/data/metabat_bins_sspec/",
            "_rosella_bins_": "/recover/data/rosella_bins/",
            "_output_prerecluster_bins_": "/recover/data/semibin_bins/output_prerecluster_bins/",
            "_output_recluster_bins_": "/recover/data/semibin_bins/output_recluster_bins/",
        }
        file_types = {
            "_maxbin2_bins_": ".fasta",
            "_metabat_bins_ssens_": ".fa",
            "_metabat_bins_sspec_": ".fa",
            "_rosella_bins_": ".fna",
            "_output_prerecluster_bins_": ".fa",
            "_output_recluster_bins_": ".fa",
        }
        for suffix, replacement in suffixes.items():
            if suffix in user_genome:
                file_type = file_types[suffix]
                return dir_prefix + re.sub(suffix, replacement, user_genome) + file_type
    return None

# Apply the function to create the 'genome_path' column
df_filtered['genome_path'] = df_filtered['user_genome'].apply(add_genome_path)

# Save the filtered DataFrame
output_csv = result_dir + "filtered_filepath_" + merged_data_csv
df_filtered.to_csv(output_csv, index=False)

print("Filtered merge_file with genome_path saved as ",output_csv)
  
#######Function to iterate through output_csv and copy the relevant files

# Define the base directory where files will be copied
mag_copy_dir = "/home/justind/oe75/csp1-3/data/mag_copies/"

# Mapping of Status values to subdirectory names
status_to_subdir = {
    "High-quality other": "high_qual_other",
    "Highly contaminated other": "contam_other",
    "Low-quality other": "low_qual_other",
    "Medium-quality other": "med_qual_other",
    "High-quality CSP1-3": "high_qual_csp1-3",
    "Medium-quality CSP1-3": "med_qual_csp1-3",
    "Low-quality CSP1-3": "low_qual_csp1-3",
    "Highly contaminated CSP1-3": "contam_csp1-3",
    "Incomplete DRAM distil process": "incomplete_dram",
    "FOLLOW-UP - Potential High-Quality CSP1-3": "follow_up_csp1-3"
}

# Import the CSV file
df = df_filtered

# Iterate through each row in the dataframe
for _, row in df.iterrows():
    genome_path = row['genome_path']
    status = row['Status']
    user_genome = row['user_genome']
    
    # Get the file extension
    _, filetype = os.path.splitext(genome_path)
    
    # Determine the subdirectory based on the Status
    sub_dir = status_to_subdir.get(status, "unknown_status")
    
    # Create the new directory path
    new_path = os.path.join(mag_copy_dir, sub_dir)
    
    # Check if the new directory exists; if not, create it
    if not os.path.exists(new_path):
        os.makedirs(new_path)

#NOTE!! below changes filetypes to .fa for easier Checkm2 handling - not sure if needed.
    # Create the new file name - don't change extension
    #new_file_name = f"{user_genome}{filetype}"
    # Change extension to .fa
    new_file_name = f"{user_genome}.fa"    


    # Create the new full file path
    new_full_path = os.path.join(new_path, new_file_name)
    
    # Copy the file
    shutil.copy2(genome_path, new_full_path)
    
    print(f"Copied {genome_path} to {new_path} as {new_file_name}")
