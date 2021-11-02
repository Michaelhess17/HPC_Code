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
slurm_ids=()
for var in $(sh "$home"/search_one.sh); do

    cd "${var:2}"
    for var2 in $(sh "$home"/search_two.sh); do
        cd "$home"
        echo "$counter"
        filename=$(echo "$root"/"$1"/"${var:2}"/"${var2:2}")
        slurm=$(sbatch run_batch.sh "$filename"| tr -dc '0-9')
        echo "Submitted batch $slurm for ${var:2}/${var2:2}"
        slurm_ids+=($slurm)
        counter=$((counter+1))

        cd "$root"
        cd "$1"/"${var:2}"
    done
cd ..
done

deplist="afterok:${slurm_ids[0]}"
for slurm_id in "${slurm_ids[@]:1}"
do
    deplist="$deplist:$slurm_id"
done


cd $home
echo $deplist
slurm_com=$(sbatch --dependency=$deplist run_summary.sh "$root"/"$1"/)
slurm=$(echo $slurm_com | tr -dc '0-9')
echo $slurm_com
echo "Submitted batch "$slurm" for Summarization"
