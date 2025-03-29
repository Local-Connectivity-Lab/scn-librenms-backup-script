set -euox
set pipefail

if [ -z "${SAS_TOKEN}" ]; then
  echo "Error: Environment variable SAS_TOKEN is not set or is empty."
  exit 1
fi

if [ -z "${SQL_PASSWORD}" ]; then                                                                                   
  echo "Error: Environment variable SQL_PASSWORD is not set or is empty."                                           
  exit 1                                                                 
fi

docker exec -it librenms_db mariadb-dump librenms -u librenms --password=$SQL_PASSWORD > /root/sqldump.sql

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
blob_name="backup_$(date +"%Y-%m-%d").tar"

# Construct the URL for the blob storage
url="https://${storage_account_name}.blob.core.windows.net/${container_name}/${blob_name}?${SAS_TOKEN}"

# Use curl to upload the file
curl -X PUT -T "${file_path}" "${url}" \
  -H "x-ms-blob-type: BlockBlob" \
  -H "Content-Type: application/octet-stream"

echo "File uploaded successfully."

rm $file_path

