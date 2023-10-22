#!/bin/bash

#This is a script to create multiple scripts which can then be submitted to SLURM

#List which should be can be the list exported from vdb_dump.sh 
#This should be in the format of no header then one line for each Sample, e.g. 
#SRR13015980
#SRR10491400
#SRR2239652

#Optional Arguments
#-n 
  #number of rows e.g. -n2 will generate two scripts for the first two SRR numbers above
#--submit_batch 
  #If user enters --sbatch_submit then it will submit the n jobs to SLURM

#Path to the file exported from vdb_dump.
input_file="/home/justind/oe75/csp1-3/data/vdb_dump/mh_pair_recover_straggler.csv"

#Location where this script will output scripts
script_output_dir="/home/justind/oe75/csp1-3/scripts"

#Where error and log output of aviary scripts will save
log_output_dir="/home/justind/oe75/csp1-3/logs/aviary/recover"

#Directory containing list of SRA files
#NOTE!! This script assumes that the rest of the files are in subdirectories of below
#e.g. the final contigs will be in the /home/justind/oe75/csp1-3/data/aviary/aviary_SRRxxxxxxx/data
sequence_input_dir="/home/justind/oe75/csp1-3/data/sra_data"

#Aviary parent directory where the final contigs will import and the recover files will export to
aviary_parent_dir="/home/justind/oe75/csp1-3/data/aviary"

#Set sbatch to off by default
submit_sbatch_switch=false
#This is number of rows for the rows of the SRR file.
num_rows=0

while getopts ":n:-:" opt; do
    case ${opt} in
        n)
            num_rows="${OPTARG}"
            ;;
        -)
            case "${OPTARG}" in
                sbatch_submit)
                    submit_sbatch_switch=true
                    ;;
                *)
                    echo "Invalid option: --${OPTARG}" >&2
                    exit 1
                    ;;
            esac
            ;;
        #For any other invalid option e.g. -q -z
        \?)
            echo "Invalid option: -${OPTARG}" >&2
            exit 1
            ;;
	#For option which requires an argument e.g. -n with no argument
        :)
            echo "Option -${OPTARG} requires an argument." >&2
            exit 1
            ;;
    esac
done

if [[ -z $num_rows ]]; then
    num_rows=$(wc -l < "$input_file")
fi

shift $((OPTIND - 1))

count=0
#Generate scripts
#Check if there's no num rows arg or the count is less than number of rows
while IFS= read -r line && ([[ -z $num_rows ]] || [[ $count -lt $num_rows ]]); do
	script_path="${script_output_dir}/c3_aviary_recover_paired_${line}.sh" 

#Put script below, using double backslash for continuing line
cat <<EOF > ${script_path}
#!/bin/bash

#SBATCH --job-name=aviary_recover_paired_${line}
#SBATCH --time=1-00:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=200G
#SBATCH --partition=short

#SBATCH --output=${log_output_dir}/%x.%j.out
#SBATCH --error=${log_output_dir}/%x.%j.err

#Add these two lines to avoid CommandNotFoundError
#source /home/justind/mambaforge/etc/profile.d/conda.sh
#source /home/justind/mambaforge/etc/profile.d/mamba.sh

source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/mamba.sh
source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/conda.sh

#Note!! For jobs which failed for aviary assemble and had to be run with megahit
#the output was in the format of final.contigs.fa These have been copied so it is
#in a consistent format with the aviary output by going into those directories and running
#mkdir data;cp final.contigs.fa ./data/final_contigs.fasta

conda activate aviary
aviary recover --assembly ${aviary_parent_dir}/aviary_${line}/data/final_contigs.fasta \\
-1 ${sequence_input_dir}/${line}_1.fastq \\
-2 ${sequence_input_dir}/${line}_2.fastq \\
-o ${aviary_parent_dir}/aviary_${line}/recover \\
-n 16 \\
--gtdb_path /home/justind/oe75/Database/GTDB-tk/release214
conda deactivate
EOF

 #Modify permissions
 chmod +x "${script_path}"
 #Submit scripts if --submit_sbatch is entered
 if $submit_sbatch_switch; then
     sbatch "${script_path}"
 fi
  
  #Increase count by one
  count=$((count + 1))
done < "$input_file"
