#!/bin/bash

PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin

# Define the directory to back up
cd ~
if [ $? -ne 0 ]; then
    echo "Failed to change directory (~)" | mail -s "Backup error" $USER
    exit 1
fi
source_dir="Documents/university/"

cd $source_dir
email_content=""
# if failed to change directory, exit
if [ $? -ne 0 ]; then
    echo "Failed to change directory ($source_dir)" | mail -s "Backup error" $USER
    exit 1
fi 
git add . && \
if [ $? -ne 0 ]; then
    echo "Failed to add files" | mail -s "Backup error" $USER
    exit 1
fi
git-commit -m "Backup"

if [ $? -ne 0 ]; then
    echo "Failed to commit" | mail -s "Backup error" $USER
    exit 1
fi

cd ~

# send email to /var/mail/$USER
echo "Backup completed" | mail -s "Backup success" $USER
