#!/bin/sh

# load env file
# remove return statements with dos2unix
dos2unix ./.env
. ./.env

# This script consolidates all the backups in the backup directory into a single
# tarball. It is intended to be run as a cron job.

# The directory where the backups are stored
dir="$BACKUP_DIR/TO_BE_DELETED"
complete_dir="$BACKUP_DIR/COMPLETE"

# Delete anything left in the backup directory from the previous run
rm -rf $dir*

# Set the backup filename to include the current date and time
backup_filename="backup_$(date +%Y-%m-%d_%H-%M-%S).tar"

# Create the backup directory if it doesn't exist
mkdir -p $dir

# Change to the backup directory
cd $dir || { mkdir -p $dir && cd $dir; }


# Look for files with the name "backup" in the config directory and copy them to the backup directory

find "$CONFIG_PATH" \
\( -path "*Backup*" -or -iname "*backup*" -or -path "*backup*" -or -iname "*.yml" -or -iname "*.env" -or -iname "*.json" -or -iname "*.conf" -or -iname "*.ini" -or -iname "*.bak" \) \
! \( -iname "*.fastresume" -or -iname "*.torrent" -or -path "*www/organizr*" -or -path "*/nextcloud-data*" \) \
-type f \
-exec cp --parents {} $dir \;


# If the name backup if in the filename or filepaths, copy them toi the backup directory
# find /media/faiyt/f \( -name "*backup*" -o -path "*/backup/*" \) -exec cp {} $dir \;

# Write the full path of all files in the backup directory to a file
find $dir -type f > $dir/files_to_be_deleted.txt
#
#pwd
#
## Create a tarball of all files in the backup directory with the date and time in the filename
tar -cvf $backup_filename -C $dir .
#
## Move backup tar file in the completed directory to a folder called COMPLETED
mv $dir/$backup_filename $complete_dir

# Copy the backup to the remote server
rclone -v copy /home/faiyt/backups/COMPLETE/$backup_filename personal:backups/

# check how many backup files are in the backups folders
# if there are more than 10, delete the oldest one

# Get the number of files in the backup directory
num_files=$(ls -1 $complete_dir | wc -l)

# If there are more than 10 files in the backup directory, delete the oldest one
if [ "$num_files" -gt 10 ]; then
  # Get the oldest file in the backup directory
  oldest_file=$(ls -1t $complete_dir | tail -1)

  # Delete the oldest file
  rm $complete_dir/$oldest_file
fi



