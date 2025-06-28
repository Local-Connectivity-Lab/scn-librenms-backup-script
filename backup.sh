set -eux
set -o pipefail

CURR_DATE=$(date +"%Y-%m-%d")
echo "Current date: $CURR_DATE"

# Note this SAS token expires on April 1 2027. You will need to create a new one then or backups will fail
if [ -z "${SAS_TOKEN_FILE:-}" ]; then
  echo "Error: Environment variable SAS_TOKEN_FILE is not set"
  exit 1
fi
SAS_TOKEN=$(cat $SAS_TOKEN_FILE)
if [ -z "${SAS_TOKEN}" ]; then
  echo "Error: Is the SAS_TOKEN_FILE file empty?"
  exit 1
fi

if [ -z "${SQL_PASSWORD_FILE:-}" ]; then
  echo "Error: Environment variable SQL_PASSWORD_FILE is not set"              
  exit 1
fi
SQL_PASSWORD=$(cat $SQL_PASSWORD_FILE)
if [ -z "${SQL_PASSWORD}" ]; then     
  echo "Error: Is the SQL_PASSWORD_FILE file empty?"                          
  exit 1                                                                 
fi

docker exec librenms_db mariadb-dump librenms -u librenms --password=$SQL_PASSWORD > /root/sqldump.sql

cd /root/librenms_deployment3/compose/librenms/
tar -cf /root/rrd.tar rrd
cd /root/
zstd rrd.tar
rm rrd.tar

tar -cf backup_package.tar sqldump.sql rrd.tar.zst
rm sqldump.sql
rm rrd.tar.zst

storage_account_name="scnbackups"
container_name="librenms-backup"
file_path="/root/backup_package.tar"
blob_name="backup_${CURR_DATE}.tar"

# Construct the URL for the blob storage
url="https://${storage_account_name}.blob.core.windows.net/${container_name}/${blob_name}?${SAS_TOKEN}"

# Use curl to upload the file
curl -X PUT -T "${file_path}" "${url}" \
  -H "x-ms-blob-type: BlockBlob" \
  -H "Content-Type: application/octet-stream"

echo "File uploaded successfully."

rm $file_path
