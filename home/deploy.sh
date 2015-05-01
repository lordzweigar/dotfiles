#!/bin/bash
# This script will attempt to symlink the files in these folders to your home directory, using stow.
# conflicts by default cause the script to stop
# first argument: user who's home dir to target, assumes /home/$user
# if a second argument exists, will force-resolve conflicts, storing old files in a folder

[ -z $1 ] && lUser=$USER || lUser=$1

#clear old conflicts file if it exists
[ -f conflicts.txt ] && rm conflicts.txt

for i in $(ls -d */); do
    #see if there will be any file conflicts:
    stow -n -t /home/$lUser/ $i 2>&1 >/dev/null |  grep -E "WARNING|All operations aborted." -v >> conflicts.txt
done

#remove conflicts if it is empty(file was created because we directed output to it(even if that output is empty):
[ ! -s conflicts.txt ] && rm conflicts.txt

if [ -f conflicts.txt ];then
    if [ -z "$2" ]; then
        echo "STOPPING DUE TO FILE CONFLICTS, check conflicts.txt"
        exit 0
    fi

    mkdir ../HOMEconflictFiles 2> /dev/null

    grep -oE "directory:.*" conflicts.txt | while read -r conflictName; do
        prefix=/home/$lUser
        #cut off the 'directory:'
        conflictFile=$(echo $conflictName | cut -c 12-)
        #make a dir if needed
        cfDir=$(echo $conflictFile | grep -oE ".+/")
        if [ ! -z "$cfDir" ]; then
            mkdir -p "../HOMEconflictFiles/$cfDir"
        fi
       mv $prefix/$conflictFile ../HOMEconflictFiles/$conflictFile
    done

    echo conflicts moved to ../HOMEconflictFiles/$conflictFile
fi

rm conflicts.txt 2> /dev/null

#conflicts resolved if we reach this point, proceed like normal:
for i in $(ls -d */); do
    stow -t /home/$lUser/ $i
done

