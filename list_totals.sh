#!/bin/bash
for var in $(squeue --me | grep -v "CG" | grep "R" | grep -Eo "[0-9]{6}")
do 
    if [ $(cat output_"$var".txt 2>/dev/null | wc -l) -lt 2018 ]
    then
        echo Process "$var" has $(cat output_"$var".txt 2>/dev/null | wc -l) lines
    fi
done

