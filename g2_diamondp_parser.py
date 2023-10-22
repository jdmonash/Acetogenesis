#!/usr/bin/env python
import argparse
import pandas as pd
def main(input, genes, subgroups, output_major, output_subgroup):
    # Part1: exploration
    cols = ['qtitle', 'stitle', 'genome']
    df = pd.read_csv(input, names = cols, sep = '\t')
    df['gene'] = df['stitle'].apply(lambda x: x.split('-')[0])
    df['gene'] = df['gene'].str.replace('SdhA_FrdA', 'SdhA-FrdA') # The notion 'SdhA_FrdA' is used in the database, correct it into 'SdhA-FrdA' for data analysis.
    ## obtain a list of genomes from the dataset
    genome_list = df['genome'].unique()
    # Part2: Parse major metabolic gene information.
    gene_list = []
    with open (genes, 'r') as f:
        for line in f:
            gene = line.strip()
            gene_list.append(gene)
    # create an empty nested dictionaries to store counts
    genome2gene2count = {}
    for genome in genome_list:
        genome2gene2count[genome] ={}
        for gene in gene_list:
            genome2gene2count[genome][gene]= 0
    
    # populate the nexted dictionary for major genes
    with open (input, 'r') as f:
        for line in f:
            qtitle, stitle, genome = line.strip().split("\t")
            gene = stitle.split('-')[0]
            if gene == "SdhA_FrdA":
                genome2gene2count[genome]["SdhA-FrdA"] += 1
            else:
                genome2gene2count[genome][gene] += 1
    df = pd.DataFrame.from_dict(genome2gene2count, orient = 'index') # directly transforms the nexted dictionary into a dataframe.
    shape = df.shape
    df.to_csv(output_major, sep = ',', index = True)
    print(f"printed dataframe for major metabolic genes with shape: {shape}")

    # Part3: Parse subgroup information
    subgroup_list = []
    with open (subgroups, 'r') as f:
        for line in f:
            subgroup = line.strip()
            subgroup_list.append(subgroup)
    #print(f"parsed a list of {len(subgroup_list)} metabolic genes subgroups")

    genome2subgroup2count = {}
    for genome in genome_list:
        genome2subgroup2count[genome] ={}
        for subgroup in subgroup_list:
            genome2subgroup2count[genome][subgroup]= 0

    # define list of subgroups identified using either brackets, square brackets or dashes
    brackets = ["RbcL", "DsrA", "CoxL", "PsaA", "PsbA", "RHO", "NxrA", "PmoA", "McrA", "AmoA"]
    sqbrackets = ["NiFe", "Fe", "FeFe", "IsoA"]
    dash = ["NosZ"]
    
    with open (input, 'r') as f:
        #subgroup_from_result = []
        for line in f:
            handle = line.strip()
            qtitle, stitle, genome = handle.split("\t")
            gene = stitle.split('-')[0]


#            if gene in brackets:
#                subgroup_raw = stitle.split('(')[1].split(')')[0]
#                subgroup = f"[{gene}] {subgroup_raw}"
#                #print(export)
#                genome2subgroup2count[genome][subgroup] += 1
#            if gene in sqbrackets:
#                subgroup_raw = stitle.split(' - ')[-1] # some lines has only one ' - ', careful
#                subgroup = subgroup_raw
#                genome2subgroup2count[genome][subgroup] += 1
#            if gene in dash:
#                subgroup_raw = stitle.split(' - ')[-1]
#                subgroup = f"[{gene}] {subgroup_raw}"
#                genome2subgroup2count[genome][subgroup] += 1
#            if gene == "SdhA_FrdA":
#                subgroup_raw = stitle.split('(')[1].split(')')[0]
#                subgroup = f"[SdhA-FrdA] {subgroup_raw}"
#                genome2subgroup2count[genome][subgroup] += 1

            if gene in brackets:
               subgroup_raw = stitle.split('(')[1].split(')')[0]
               subgroup = f"[{gene}] {subgroup_raw}"
               if genome not in genome2subgroup2count:
                   genome2subgroup2count[genome] = {}
               if subgroup not in genome2subgroup2count[genome]:
                   genome2subgroup2count[genome][subgroup] = 0
               genome2subgroup2count[genome][subgroup] += 1

            if gene in sqbrackets:
               subgroup_raw = stitle.split(' - ')[-1] # some lines has only one ' - ', careful
               subgroup = subgroup_raw
               if genome not in genome2subgroup2count:
                   genome2subgroup2count[genome] = {}
               if subgroup not in genome2subgroup2count[genome]:
                   genome2subgroup2count[genome][subgroup] = 0
               genome2subgroup2count[genome][subgroup] += 1

            if gene in dash:
               subgroup_raw = stitle.split(' - ')[-1]
               subgroup = f"[{gene}] {subgroup_raw}"
               if genome not in genome2subgroup2count:
                   genome2subgroup2count[genome] = {}
               if subgroup not in genome2subgroup2count[genome]:
                   genome2subgroup2count[genome][subgroup] = 0
               genome2subgroup2count[genome][subgroup] += 1

            if gene == "SdhA_FrdA":
              subgroup_raw = stitle.split('(')[1].split(')')[0]
              subgroup = f"[SdhA-FrdA] {subgroup_raw}"
              if genome not in genome2subgroup2count:
                  genome2subgroup2count[genome] = {}
              if subgroup not in genome2subgroup2count[genome]:
                  genome2subgroup2count[genome][subgroup] = 0
              genome2subgroup2count[genome][subgroup] += 1


    df = pd.DataFrame.from_dict(genome2subgroup2count, orient = 'index') # each key of the dictionary (genomes in this case) becomes a row in the DataFrame
    shape = df.shape
    df.to_csv(output_subgroup, sep = ',', index = True)
    print(f"printed dataframe for subgroups of metabolic genes with shape: {shape}")           

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Parses output from Diamond blastp with Genomes.",
        epilog="example: ./diamondp_parser.py /home/gnii0001/09_cave/result/metabolism/func51_mags/dereplicated/summary/Funcgenes_51_filtered.summary.tsv genes.txt subgroups.txt major.csv subgroup.csv")
    parser.add_argument("input", help="result from diamondp run for MAGs")
    parser.add_argument("genes", help="list of metabolic genes")
    parser.add_argument("subgroups", help="list of subgroups for metabolic genes")
    parser.add_argument("output_major", help="summary table for major metabolic genes")
    parser.add_argument("output_subgroup", help="summary table for subgroups of metabolic genes")
    args = parser.parse_args()
    main(args.input, args.genes, args.subgroups, args.output_major, args.output_subgroup)
