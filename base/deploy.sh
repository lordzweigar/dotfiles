#!/bin/bash
# This script will attempt to symlink the files in these folders to the root directory, using stow.
# conflicts by default cause the script to stop
# if an argument exists, will force-resolve conflicts, storing old files in a folder ../BASEconflictFiles

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#clear old conflicts file if it exists
if [ -f conflicts.txt ]; then
    rm conflicts.txt
fi

for i in $(ls -d */); do
    #see if there will be any file conflicts:
    stow -n -t / $i 2>&1 >/dev/null |  grep -E "WARNING|All operations aborted." -v >> conflicts.txt
done

#remove conflicts if it is empty(file was created because we directed output to it(even if that output is empty):
if [ ! -s conflicts.txt ]; then
    rm conflicts.txt
fi

if [ -f conflicts.txt ];then
    if [ -z "$1" ]; then
        echo "STOPPING DUE TO FILE CONFLICTS, check conflicts.txt"
        exit 0
    fi

    mkdir ../BASEconflictFiles 2> /dev/null

    grep -oE "directory:.*" conflicts.txt | while read -r conflictName; do
        #cut off the 'directory:' text
        conflictFile=$(echo $conflictName | cut -c 12-)
        #make a dir if needed
        cfDir=$(echo $conflictFile | grep -oE ".+/")
        if [ ! -z "$cfDir" ]; then
            mkdir -p "../BASEconflictFiles/$cfDir"
        fi
        mv /$conflictFile ../BASEconflictFiles/$conflictFile
    done

    echo conflicts moved to ../BASEconflictFiles/$conflictFile
fi

rm conflicts.txt 2> /dev/null

#conflicts resolved if we reach this point, proceed like normal:
for i in $(ls -d */); do
    stow -t / $i
done

