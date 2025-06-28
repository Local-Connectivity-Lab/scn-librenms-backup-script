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

if [ -z "${WEBHOOK_URL_FILE:-}" ]; then
  echo "WEBHOOK_URL_FILE needs to be set"
  exit 1
fi
WEBHOOK_URL="$(cat $WEBHOOK_URL_FILE)"
if [ -z "${WEBHOOK_URL}" ]; then
  echo "Error: Is the WEBHOOK_URL file empty?"
  exit 1
fi

send_message() {
        local timestamp=$(date +'%Y-%m-%dT%H:%M:%S.%3N%:z')

        local response=$(curl -s -w "\n%{http_code}" -H "Content-Type: application/json" -X POST -d "{\"content\": \"[$timestamp] $1\"}" $WEBHOOK_URL)
        local body=$(echo "$response" | sed '$d')
        local status=$(echo "$response" | tail -n1)

        if [ "$status" -ne 204 ]; then
                curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": \"Error trying to send message\"}" $WEBHOOK_URL
                exit 1
        fi
}

send_message "Backing up librenms to azure <@405064409396805632>..."


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
curl -f -X PUT -T "${file_path}" "${url}" \
  -H "x-ms-blob-type: BlockBlob" \
  -H "Content-Type: application/octet-stream"

echo "File uploaded successfully."

rm $file_path

send_message "Backup succeeded"
