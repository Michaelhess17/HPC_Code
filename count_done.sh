#!/bin/bash
counter=0
counter3=0
for var in $(find . -name "output_*" -type f)
do
    if echo "$var" | grep -Eoq "[0-9]{6}"
    then
        var=$(echo "$var" | grep -Eo "[0-9]{6}")
    else 
        continue
    fi
    if [ $(cat output_"$var".txt | wc -l) -ge 2018 ]
    then
        ((counter++))
    else
        sum=$(cat output_process.txt | grep "Summarization" | grep -Eo "[0-9]{6}") 
        if [ "$var" == "$sum" ]
        then
            continue
        else 
            ((counter3++))
        fi
    fi
done
counter1=0
counter2=0
for var in $(squeue --me  | grep -v "CG" | grep -Eo "[0-9]{6}")
do 
    if [ -e output_"$var".txt ]
        then
        if [ $(cat output_"$var".txt | wc -l) -lt 2018 ]
        then
            ((counter1++))
        fi
    else
        ((counter2++))
    fi
done
total=$(./get_number_expected.sh | tail -1 | awk '{print $8}')
echo "There are "$counter" finished, "$counter1" running, $(expr "$counter3" - "$counter1") failed, and "$counter2" queued processes"
echo "There are also $(expr "$total" - "$counter2" - "$counter1" - "$counter" - "$counter3" + "$counter1") processes waiting to be queued."
