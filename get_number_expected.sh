#!/bin/bash
root=`./get_root.sh`
folder=$(head -1 output_process.txt | awk '{print $5}')
cd "$root"
cd "$folder"
counter=0

IFS=$'\n'
for var in $(sh ~/search_one.sh); do
    cd "${var:2}"
    for var2 in $(sh ~/search_two.sh); do      
	counter=$((counter+1))
    echo "$var"/"$var2"
    done
cd ..
done
echo "The current litter ($folder), there will be $counter animal folders"
