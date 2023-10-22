#!/usr/bin/env python
import argparse
import pandas as pd
import csv

#Note: Changed this from greening lab script:
#1) Changed to import the gathered files
#2) This means "user_genome" is the primary key.
#3) Also added printing the lines to make sure data looks OK at each step
#4) This version doesn't merge correctly - to do merge with other data

print("\n--------PARSE METADATA--------")
#1.  function to parse metadata
def annotate_accession (input):
    accession2name = dict()
    accession2complex = dict()
    with open (input, "r") as f:
        for line in f:
            handle = line.strip().split("\t")
            accession, gene_name, enzyme_complex, organism = handle
            accession2name[accession] = gene_name
            accession2complex[accession] = enzyme_complex
        print(f"\ndictionary accession2name contains {len(accession2name)} mappings")
        print(f"dictionary accession2complex contains {len(accession2complex)} mappings")
    return(accession2name, accession2complex)
accession2name, accession2complex = annotate_accession("/home/justind/oe75/csp1-3/data/acetogenesis_db/reference_sequences_metadata.tsv")

#2.  function to parse taxonomy
#Note this just imports gtdb_gather.tsv which already gathers all the bacterial/archaea classification data

print("\n--------PARSE TAXONOMY--------")
def parse_taxonomy (input):
    df = pd.read_csv(input, sep='\t')
    genome2taxonomy = dict(zip(df['user_genome'], df['classification']))
    
    print(f"\ndictionary genome2taxonomy contains {len(genome2taxonomy)} mappings")
    
    print("\nFirst 5 entries in genome2taxonomy:")
    for i, (user_genome, classification) in enumerate(genome2taxonomy.items()):
        print(f"{user_genome}: {classification}")
        if i == 5:
            break

genome2taxonomy = parse_taxonomy("/home/justind/oe75/csp1-3/data/gtdbtk/gtdb_gather.tsv")

print("\n--------PARSE QUALITY----------")

#3. Get quality from Checkm2
#This might need to be modified...

def parse_quality (input):
    df = pd.read_csv(input, sep='\t')  
    genome2completeness = dict(zip(df['user_genome'], df['Completeness']))
    genome2contamination = dict(zip(df['user_genome'], df['Contamination']))

    print(f"\ndictionary genome2completeness contains {len(genome2completeness)} mappings")
    print(f"dictionary genome2contamination contains {len(genome2contamination)} mappings")
    #return (genome2completeness, genome2contamination)

    print("\nFirst 5 entries in genome2completeness:")
    for i, (user_genome, completeness) in enumerate(genome2completeness.items()):
        print(f"{user_genome}: {completeness}")
        if i == 5:
            break

    print("\nFirst 5 entries in genome2contamination:")
    for i, (user_genome, contamination) in enumerate(genome2contamination.items()):
        print(f"{user_genome}: {contamination}")
        if i == 5:
            break
    return (genome2completeness, genome2contamination)

genome2completeness, genome2contamination = parse_quality("/home/justind/oe75/csp1-3/data/checkm2/checkm2_gather.tsv")


def process_diamondp_output (input, accession2name, accession2complex,  output):
    df = pd.read_csv(input, sep = "\t", header = None, skipinitialspace = True)
    df.columns = ["qtitle", "accession", "genome"]
    df["gene_name"] = df["accession"].map(accession2name)
    df["enzyme_complex"] = df["accession"].map(accession2complex)
    #df["taxonomy"] = df["genome"].map(genome2taxonomy)
    #df["completeness"] = df["genome"].map(genome2completeness)
    #df["contamination"] = df["genome"].map(genome2contamination)
    
    wide_df = df.pivot_table(index= ["genome"],columns = ["enzyme_complex", "gene_name"],values = "qtitle",aggfunc=len,fill_value= 0)
    wide_df = wide_df.reset_index()
    wide_df.to_csv(output, sep = ",", index = False)

process_diamondp_output(
"/home/justind/oe75/csp1-3/data/aceto_diamond_blastp/acetogens/summary/acetogenesis_prefiltered.summary.tsv",
accession2name,
accession2complex,
#genome2taxonomy,
#genome2completeness,
#genome2contamination,
"/home/justind/oe75/csp1-3/results/acetogenesis_prefiltered_annotated.csv")
