#!/bin/bash
root=`./get_root.sh`
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
            file=$(cat output_process.txt | grep "$var" | awk '{print $5}')
            #echo "$file"
            age_folder=$(echo "$file" | awk -F/ '{print $1}')
            #echo "$age_folder"
            anim_name=$(echo "$file" | awk -F/ '{print $2}')
            filepath=$(find "$root"/"$folder"/"$age_folder"/ -name "$anim_name*")
            #echo "$filepath"
            
            slurm=$(sbatch run_batch.sh "$filepath" | tr -dc '0-9')
            echo "Submitted batch "$slurm" for "$file"" >> failed_processes.txt
            tail -1 failed_processes.txt
            rm output_"$var".txt
            rm error_"$var".err
            while [ ! -f $(echo "output_""$slurm"".txt") ]
            do
                sleep 5s
            done 
            while [ $(cat "output_""$slurm"".txt" | wc -l) -le 2 ]
            do
                sleep 10s
            done
        fi
    fi 
done
