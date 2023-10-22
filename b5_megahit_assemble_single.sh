#!/bin/bash

#This is a script to create multiple scripts which can then be submitted to SLURM
#Note this doesn't use aviary but just uses MEGAHIT because Aviary couldn't handle some single reads.


#List which should be can be the list exported from vdb_dump.sh 
#This should be in the format of no header then one line for each Sample, e.g. 
#SRR13015980
#SRR10491400
#SRR2239652

#Optional Arguments
#-n 
  #number of rows e.g. -n2 will generate two scripts for the first two SRR numbers above
#--sbatch_submit 
  #If user enters --sbatch_submit then it will submit the n jobs to SLURM

#Path to the file exported from vdb_dump.
input_file="/home/justind/oe75/csp1-3/data/vdb_dump/last_but_notleast.csv"

#Location where this script will output scripts
script_output_dir="/home/justind/oe75/csp1-3/scripts"

#Location where error and log output of aviary scripts will save
log_output_dir="/home/justind/oe75/csp1-3/logs/aviary/assemble"

#Directory containing list of SRA files
sequence_input_dir="/home/justind/oe75/csp1-3/data/sra_data"

#Where the aviary script will export the data to
aviary_export_dir="/home/justind/oe75/csp1-3/data/aviary"

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
	script_path="${script_output_dir}/b6_megahit_assemble_single_${line}.sh" 

#Put script below, using double backslash for continuing line
cat <<EOF > ${script_path}
#!/bin/bash

#SBATCH --job-name=megahit_assemble_single_${line}
#SBATCH --time=1-00:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=256G
#SBATCH --partition=short

#SBATCH --output=${log_output_dir}/%x.%j.out
#SBATCH --error=${log_output_dir}/%x.%j.err

#m -600 is 600GB. Make sure n m match cpus-per-task and mem

#Add these two lines to avoid CommandNotFoundError
#source /home/justind/mambaforge/etc/profile.d/conda.sh
#source /home/justind/mambaforge/etc/profile.d/mamba.sh

source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/mamba.sh
source /home/justind/oe75/csp1-3/tools/mambaforge/etc/profile.d/conda.sh

#Not sure if this is needed....
conda activate base

#Min count is minimum number of k-mers
#This will filter out any k-mers appearing once which helps with the quality
#By removing sequences with errors.
#Also no need to specify memory with megahit as it will use 

megahit \\
-r ${sequence_input_dir}/${line}.fastq \\
--out-dir ${aviary_export_dir}/aviary_${line} \\
--min-count 2 \\
--k-list 27,37,47,57,67,77,87,97,107,117,127 \\
--num-cpu-threads 12

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
