#!/usr/bin/env python
import argparse
import pandas as pd
import numpy as np
from datetime import datetime

#This is a slightly modified version of the script on Github
#Differences - This doesn't add coverm and coassembly info
#But this adds info from Sandpiper and DRAM

#IMPORT SANDPIPER
#Import all sandpiper rows as only the ones which have been classified will be included in merge below
df_sandpiper = pd.read_csv('/home/justind/oe75/csp1-3/data/vdb_dump/p__CSP1-3_all.csv', usecols=[0,1,2,3,4])

#IMPORT GTDB-TK CLASSIFICATION
#Taxonmy section was done differently to the script on GitHub used as the basis of this
#My step was done in the gtdbtk gather script
df_taxonomy = pd.read_csv('/home/justind/oe75/csp1-3/data/gtdbtk/gtdb_gather.tsv', sep='\t', usecols=[0,1]) 

# Print first 5 rows of df_taxonomy
print("First 5 rows of df_taxonomy:")
print(df_taxonomy.head())


#IMPORT METABOLISM
#These are the Greening lab curated files...
# Read major.csv and subgroups.csv, assuming they have an unnamed index column
df_major = pd.read_csv('/home/justind/oe75/csp1-3/data/diamond_blastp/parser_py_outputs/major.csv', index_col=0)
df_major = df_major.reset_index().rename(columns={'index': 'user_genome'})
df_subgroups = pd.read_csv('/home/justind/oe75/csp1-3/data/diamond_blastp/parser_py_outputs/subgroup.csv', index_col=0)
df_subgroups = df_subgroups.reset_index().rename(columns={'index': 'user_genome'})

# Print first 5 rows of df_major
print("First 5 rows of df_major:")
print(df_major.head())

# Print first 5 rows of df_subgroups
print("First 5 rows of df_subgroups:")
print(df_subgroups.head())


#IMPORT CHECKM2 QUALITY
df_quality = pd.read_csv('/home/justind/oe75/csp1-3/data/checkm2/checkm2_gather.tsv', sep='\t', usecols=[1,2,15])
#df_quality = df_quality.rename(columns={'Name': 'user_genome'})
# Print first 5 rows of df3
print("First 5 rows of df_quality:")
print(df_quality.head())

#Add column to taxonomy data to merge with sandpiper
df_taxonomy['sample'] = df_taxonomy['user_genome'].str.split('_').str[0]

#Import DRAM files
#Don't need the second column though which is genome
df_dram_prod = pd.read_csv('/home/justind/oe75/csp1-3/data/dram/gather/dram_product_gather.tsv', sep='\t', usecols=lambda x: x != 1)
df_dram_stat = pd.read_csv('/home/justind/oe75/csp1-3/data/dram/gather/dram_gemome_stat_gather.tsv', sep='\t', usecols=lambda x: x != 1)

# TIDY UP
# Remove leading/trailing spaces and ensure case matching
df_taxonomy['user_genome'] = df_taxonomy['user_genome'].str.strip()
df_major['user_genome'] = df_major['user_genome'].str.strip()
df_subgroups['user_genome'] = df_subgroups['user_genome'].str.strip()
df_quality['user_genome'] = df_quality['user_genome'].str.strip()
df_dram_prod['user_genome'] = df_dram_prod['user_genome'].str.strip()
df_dram_stat['user_genome'] = df_dram_stat['user_genome'].str.strip()


# MERGE
# Merge df_taxonomy with subgroups based on the first column of df_taxonomy and the index of df_subgroups
df1 = df_taxonomy.merge(df_quality, on='user_genome', how='left')
df2 = df1.merge(df_sandpiper, on = 'sample', how='left')
df3 = df2.merge(df_dram_stat, on = 'user_genome', how='left')
df4 = df3.merge(df_major, on='user_genome', how='left')
df5 = df4.merge(df_subgroups, on='user_genome', how='left')
df6 = df5.merge(df_dram_prod, on = 'user_genome', how='left')

#Fill Blanks with 0
df_final = df6.fillna(0)

# Print first 5 rows of df_subgroups_merge
print("First 5 rows of df_subgroups_merge:")
print(df_final.head())

#Move columns in order...
cols_to_move = ['sample', 'relative_abundance','coverage','organism','release_year']

#Surely there's a less convoluted way to do this....
df_final = df_final[cols_to_move + [col for col in df_final.columns if col not in cols_to_move]]

#Create column to categorise genomes
#Change column types so comparisons can work
df_final['5S rRNA'] = df_final['5S rRNA'].astype(str)
df_final['16S rRNA'] = df_final['16S rRNA'].astype(str)
df_final['23S rRNA'] = df_final['23S rRNA'].astype(str)
df_final['tRNA count'] = df_final['tRNA count'].astype(int)

#Add RNA column counts
def rRNA_5S_count(row):
    value = row['5S rRNA']
    if value == "0":
        return 0
    elif " present" in value:
        return int(value.replace(" present", ""))
    else:
        return 1

def rRNA_16S_count(row):
    value = row['16S rRNA']
    if value == "0":
        return 0
    elif " present" in value:
        return int(value.replace(" present", ""))
    else:
        return 1

def rRNA_23S_count(row):
    value = row['23S rRNA']
    if value == "0":
        return 0
    elif " present" in value:
        return int(value.replace(" present", ""))
    else:
        return 1

#Create MAG status column to allow for filtering of particular MAGs
def determine_status(row):
    classification = row['classification']
    completeness = row['Completeness']
    contamination = row['Contamination']
    num_scaffolds = row['number of scaffolds']
    rRNA_5S = row['5S rRNA']
    rRNA_16S = row['16S rRNA']
    rRNA_23S = row['23S rRNA']
    tRNA = row['tRNA count']

    contains_CSP13 = 'CSP1-3' in classification

    if contains_CSP13 and completeness > 90 and contamination < 5 and num_scaffolds == 0:
        return "FOLLOW-UP - Potential High-Quality CSP1-3"
    elif num_scaffolds == 0:
        return "Incomplete DRAM distil process"
    elif contains_CSP13 and completeness > 90 and contamination < 5 and rRNA_5S != "0" and rRNA_16S != "0" and rRNA_23S != "0" and tRNA >= 18:
        return "High-quality CSP1-3"
    elif not contains_CSP13 and completeness > 90 and contamination < 5 and rRNA_5S != "0" and rRNA_16S != "0" and rRNA_23S != "0" and tRNA >= 18:
        return "High-quality other"
    elif contains_CSP13 and completeness >= 50 and contamination < 10:
        return "Medium-quality CSP1-3"
    elif not contains_CSP13 and completeness >= 50 and contamination < 10:
        return "Medium-quality other"
    elif contains_CSP13 and completeness < 50 and contamination < 10:
        return "Low-quality CSP1-3"
    elif not contains_CSP13 and completeness < 50 and contamination < 10:
        return "Low-quality other"
    elif contains_CSP13 and contamination >= 10:
        return "Highly contaminated CSP1-3"
    elif not contains_CSP13 and contamination >= 10:
        return "Highly contaminated other"
    else:
        return "CHECK python script - Other condition"

# Create series for each new column
status_series = df_final.apply(determine_status, axis=1)
rRNA_5S_series = df_final.apply(rRNA_5S_count, axis=1)
rRNA_16S_series = df_final.apply(rRNA_16S_count, axis=1)
rRNA_23S_series = df_final.apply(rRNA_23S_count, axis=1)

#Concatenate all new columns at once
new_columns = pd.concat([status_series.rename('Status'),
                         rRNA_5S_series.rename('5S rRNA count'),
                         rRNA_16S_series.rename('16S rRNA count'),
                         rRNA_23S_series.rename('23S rRNA count')], axis=1)

# Concatenate the new columns with the original dataframe
df_final = pd.concat([df_final, new_columns], axis=1)

#Move the status column to the start and the three count columns to after the tRNA count column:
# Get the list of current columns
cols = list(df_final.columns)

# Move 'Status' to the start
cols.insert(0, cols.pop(cols.index('Status')))

# Find the index of the 'tRNA count' column
index_of_tRNA = cols.index('tRNA count')

# Insert the desired columns right after 'tRNA count'
cols.insert(index_of_tRNA + 1, cols.pop(cols.index('5S rRNA count')))
cols.insert(index_of_tRNA + 2, cols.pop(cols.index('16S rRNA count')))
cols.insert(index_of_tRNA + 3, cols.pop(cols.index('23S rRNA count')))

#Create and write dataframe so dRep can filter later
#e.g. the dRep funtion can filter for only high quality CSP1-3 or for medium and high quality other etc...
#dRep also can't use the final file as this is a merge with a dataset with two header rows, so export file here.
df_for_drep = df_final[['Status','user_genome']]
df_for_drep.to_csv("/home/justind/oe75/csp1-3/results/genome_list_for_drep.csv", sep=",")

# Rearrange the dataframe according to the modified columns order
df_final = df_final[cols]

#Now clear any relative abundances or coverage for non CSP1-3 genomes as these are from Sandpiper
df_final.loc[~df_final['classification'].str.contains('CSP1-3', case=False, na=False), ['relative_abundance', 'coverage']] = np.nan

#Remove genome_x and genome_y columns.
#There's probably a way to exclude these in the merge.
df_final = df_final.drop(columns=['genome_x', 'genome_y'])

#######################
#The final data to be merged is the Greenling lab acetogenesis DIAMOND data
#However, this is a little unusual in that it has two header rows, so the df_final should be modif
#There's likely a more elegant way to do this but this works so

#First count the number of columns so these can be blanked after the merge
#Dynamic in case new columns are introduced
df_final_pre_aceto_merge_col_count = df_final.shape[1]

#First duplicate the header row as the first row
header_duplicate_row_1 = pd.DataFrame([df_final.columns], columns=df_final.columns)

#Insert the headers as the first row
df_final = pd.concat([header_duplicate_row_1, df_final]).reset_index(drop=True)

#Update the header row to "genome" as this will be merged with the below data
df_final = df_final.rename(columns={"user_genome": "genome"})

#Get the accession data from the acetogenesis metadata

def annotate_accession(input_path):
    # Read the TSV file into a DataFrame
    df = pd.read_csv(input_path, sep='\t', header=None, names=['accession', 'gene_name', 'enzyme_complex', 'organism'])

    # Create dictionaries directly from DataFrame
    accession2name = df.set_index('accession')['gene_name'].to_dict()
    accession2complex = df.set_index('accession')['enzyme_complex'].to_dict()

    print(f"\ndictionary accession2name contains {len(accession2name)} mappings")
    print(f"dictionary accession2complex contains {len(accession2complex)} mappings")

    return accession2name, accession2complex

#Note this has had the trailing spaces removed
accession2name, accession2complex = annotate_accession("/home/justind/oe75/csp1-3/data/acetogenesis_db/reference_sequences_metadata_nospace.tsv")

def process_diamondp_output (input, accession2name, accession2complex):
    df = pd.read_csv(input, sep = "\t", header = None, skipinitialspace = True)
    df.columns = ["qtitle", "accession", "genome"]
    df["gene_name"] = df["accession"].map(accession2name)
    df["enzyme_complex"] = df["accession"].map(accession2complex)
    
    wide_df = df.pivot_table(index= ["genome"],columns = ["enzyme_complex", "gene_name"],values = "qtitle",aggfunc=len,fill_value= 0)
    wide_df = wide_df.reset_index()
    return wide_df

df_aceto = process_diamondp_output(
    "/home/justind/oe75/csp1-3/data/aceto_diamond_blastp/acetogens/summary/acetogenesis_prefiltered.summary.tsv",
    accession2name,
    accession2complex)

#Cannot for the life of me figure out get the  multilevel df to merge with the single level without fucking up the column headers
#So just gonna write it to CSV then reimport so it pisses off the multi headers

df_aceto.to_csv('/home/justind/oe75/csp1-3/results/aceto_tmp.csv', index=False)
df_aceto = pd.read_csv('/home/justind/oe75/csp1-3/results/aceto_tmp.csv')
df_aceto.iloc[0,0]="user_genome"


#Now, merge the two DataFrames
df_final = df_final.merge(df_aceto, on="genome", how="left")

#Now remove all values from the header of the dataframe up to where the pre-aceto-merge data is.
#ie. the extra header row for the aceto data will be the only data there.
df_final.columns = [''] * df_final_pre_aceto_merge_col_count + list(df_final.columns[df_final_pre_aceto_merge_col_count:])

#Replace all blanks with 0's
df_final.replace("", 0, inplace=True)
df_final.fillna(0, inplace=True)

#Get current time
now = datetime.now()

#Create a timestamp:
timestamp = now.strftime('%H%M_%d_%m_%Y')

#df_aceto.to_csv("/home/justind/oe75/csp1-3/results/acetogenesis_prefiltered_annotated_{timestamp}.csv", sep=",", index=False)

#Append timestamp to filename:
merged_data = f'/home/justind/oe75/csp1-3/results/merged_data_{timestamp}.csv'
aceto_data = f'/home/justind/oe75/csp1-3/results/acetogenesis_prefiltered_annotated_{timestamp}.csv'

# Save the final dataframe to a new csv file
df_final.to_csv(merged_data, index=False)
df_aceto.to_csv(aceto_data, sep=",", index=False)
