set -e

if [ -z "$MYSQL_PASSWORD" ]; then
    echo "set the MYSQL_PASSWORD env var in order to back up the database"
    exit 1
fi

if [ -z "$BACKUP_FOLDER" ]; then
    echo "set the BACKUP_FOLDER env var to let the script know where to put the backup files"
    exit 1
fi

backup_folder_folder=$BACKUP_FOLDER/$(date +%s)

mkdir $backup_folder_folder
cd ansible
source .venv/bin/activate
ansible-playbook -i inventory.ini playbook.yml -e MYSQL_PASSWORD="$MYSQL_PASSWORD" -e BACKUP_FOLDER="$backup_folder_folder"
deactivate
cd ..

# delete the oldest backup since this one completed sucessfully
sorted_dirs=$(ls -d $BACKUP_FOLDER/* | sort)
if [ "$sorted_dirs" != "" ]; then
    # There should be more than 2 items, the one that was just backed up and this script
    if [ $(echo "$sorted_dirs" | wc -l) -ge 2 ]; then
        # Delete the first item
        rm -r $(echo "$sorted_dirs" | head -n 1)
    fi
fi
