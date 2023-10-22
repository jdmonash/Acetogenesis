#!/bin/bash

#This is a script to extract  of a sequencing run (SRR file) using the vdp-dump command from SRA Toolkit

#Extract list as csv file from Sandpiper https://sandpiper.qut.edu.au/
#e.g. for p__CSP1-3 the CSV will download via https://sandpiper.qut.edu.au/api/taxonomy_search_csv/p__CSP1-3

#Example command for generating list for p__CSP1-3 with at least 5% relative abundance and at least 20 minimum coverage is:
#get_vdp_dump_size.sh -t p__CSP1-3 -r5 -c20
#Can add a row to select by organism as well
#get_vdp_dump_size.sh -t p__CSP1-3 -r5 -c20 -o hot springs metagenome


# Example output files:
# p_CSP1-3_all.csv - This is all records from sandpiper for that taxonomy
# p_CSP1-3_r5_c20.csv - This is just the filtered records based on the above minimum relative abundance and coverages.


#Get arguments
while getopts t:r:c:o: arg

do
  case "${arg}" in
    t) taxonomy=${OPTARG};;
    r) relative_abundance_min=${OPTARG};;
    c) coverage_min=${OPTARG};;
    o) organism=${OPTARG};;
  esac
done

#Create filtered CSV - filtered file from Sandpiper
FILTERED_CSV=~/oe75/csp1-3/data/vdb_dump/${taxonomy}_r${relative_abundance_min}_c${coverage_min}.csv
TEMP_CSV=~/oe75/csp1-3/data/vdb_dump/${taxonomy}_r${relative_abundance_min}_c${coverage_min}_temp.csv
UPDATED_CSV=~/oe75/csp1-3/data/vdb_dump/${taxonomy}_r${relative_abundance_min}_c${coverage_min}_updated.csv

mkdir ~/oe75/csp1-3/data/vdb_dump/
wget https://sandpiper.qut.edu.au/api/taxonomy_search_csv/$taxonomy -O ~/oe75/csp1-3/data/vdb_dump/${taxonomy}_all.csv

#Filter for above including organism
awk -F ',' -v r=$relative_abundance_min -v c=$coverage_min -v o="$organism" 'NR == 1 || $2 >= r && $3 >= c && $4 ~o' ~/oe75/csp1-3/data/vdb_dump/${taxonomy}_all.csv > $FILTERED_CSV

#Now go through the above CSV to query via vbd-dump each sample
echo Now running VDB dump
echo

#Below looks up the file information from vdb-dump, then extracts any information after the "Size" line, then removes commas from the numbers,
#Then gets the result and prints the first 5 columns
awk -F',' '{cmd = "vdb-dump --info " $1 " --verbose | grep -Po \"size   : \\\\K.*\" | sed \"s/,//g\""; cmd | getline size_extract ; close(cmd);
print $1 "," $2 "," $3 "," $4 "," $5 "," $6 "," size_extract }' $FILTERED_CSV > $TEMP_CSV

#Add the size_extract column to the updated csv
sed -i '1 s/$/size_extract,/' $TEMP_CSV
sed -i '1 s/$/final_size_estimate_gb/' $TEMP_CSV

#Calculate the estimated size, note that https://hpc.nih.gov/apps/sratoolkit.html recommends that the temp file will
#be 6x larger and the output file will be 7x larger, so the below is just 7x for the final
#However not sure if it may be temprorarily twice that size if the temp and final files are stored at the same time.

awk -F "," '(NR>1)''{$8=($7/1000000000)*7} {print $1,$2,$3,$4,$5,$6,$7,$8}' OFS="," $TEMP_CSV > $UPDATED_CSV

#Save last_acc which will be the accession file to run fasterq dump on
awk -F "," 'NR>1 {print $1}' $TEMP_CSV > ~/oe75/csp1-3/data/vdb_dump/sample_only.csv

#remove the unneeded file.
rm $TEMP_CSV
