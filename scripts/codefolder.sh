#!/bin/zsh


echo "---------------------Coding new folder and file creator------------------\n"
ls ~/{code-ssd,code-hdd}


folderchooser(){

    echo "Enter your folder name from here ? : "
    read foldername
    echo "You choose the folder $foldername. Is this correct ?  y or n : "
    read choiceverify
    return choiceverify
    
}


while true
do
    

    choiceverify = folderchooser


    if [ $choiceverify= "y" ]
    then
        break
    elif [ $choiceverify="n" ]
    then
        folderchooser
    else
    then
        continue      
    fi


done



echo "Enter foldername filename extension ? "

mkdir -p $foldername && touch "$foldername/$file.$extension"



