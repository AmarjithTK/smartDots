#!/bin/zsh


echo "What is the name of new code-program ? Name it with hypen , eg : node-js"
read foldername

while true
do
    echo "HDD or SSD to use ? [1,2] for HDD,SSD , press q for quit : "
    read drive
    if [ $drive= "1" ]
    then
        folder="code-hdd/$foldername"
    elif [ $drive="2" ]
    then
        folder="code-ssd/$foldername"
    elif [ $drive="q" ]
    then
        exit 1
    else
    then
        continue      
    fi

    mkdir -p "$foldername"
    break;

done

