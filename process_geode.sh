#!/bin/bash
echo "Running Modol process on "$1""
echo "Cleaning outputs older than 5 minutes"
find . -name "output*" -type f -mmin +5 -delete
find . -name "error*" -type f -mmin +5 -delete
rm failed_processes.txt 2>/dev/null

# Begin queuing processes
home=`pwd`
root=`./get_root.sh`
cd "$root"
cd "$1"
counter=0

IFS=$'\n'
for var in $(sh "$home"/search_one.sh); do

    cd "${var:2}"
    for var2 in $(sh "$home"/search_two.sh); do
        cd "$home"
        echo "$counter"
        slurm=$(sbatch run_batch.sh "$root"/"$1"/"${var:2}"/"${var2:2}" | tr -dc '0-9')
        echo "Submitted batch $slurm for ${var:2}/${var2:2}"
        counter=$((counter+1))

        cd "$root"
        cd "$1"/"${var:2}"
    done
cd ..
done
echo "Waiting for running jobs to complete..."
while [ $(squeue --me | grep '[0-9]' | grep -v "CG" | wc -l) -gt 0 ]
do
    sleep 10s
done

cd "$home"
echo "Finished running main process... checking for failed jobs"
cd ~
folder=$(head -1 output_process.txt | awk '{print $5}')
counter=0
echo "$folder"
for var in $(find . -name "output_*" -type f | grep -Eo "[0-9]{6}")
do 
    if [ $(cat output_"$var".txt | wc -l) -lt 2018 ]
    then
        if squeue --me | grep -q "$var";
        then
            ((counter++))
        else
            echo "Process "$var" has failed"
            file=$(cat "$home"/output_process.txt | grep "$var" | awk '{print $5}')
            #echo "$file"
            age_folder=$(echo "$file" | awk -F/ '{print $1}')
            #echo "$age_folder"
            anim_name=$(echo "$file" | awk -F/ '{print $2}')
            filepath=$(find "$root"/"$folder"/"$age_folder"/ -name "$anim_name*")
            #echo "$filepath"
            
            slurm=$(sbatch run_batch_again.sh "$filepath" | tr -dc '0-9')
            echo "Submitted batch "$slurm" for "$file"" >> failed_processes.txt
            tail -1 failed_processes.txt
            rm output_"$var".txt
            rm error_"$var".err
        fi
    fi 
done
echo "All batch processes have been submitted. \n"
echo "Waiting for processes to finish to run summary"
while [ $(squeue --me | grep '[0-9]' | grep -v "CG" | wc -l) -gt 0 ]
do
    sleep 10s
done

echo "Summarizing outputs"
slurm=$(sbatch run_summary.sh "$root"/"$1"/ | tr -dc '0-9')
echo "Submitted batch "$slurm" for Summarization" >> output_process.txt
