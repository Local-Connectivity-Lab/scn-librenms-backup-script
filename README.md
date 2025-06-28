Backs up librenms to azure. It is meant to run from the librenms server

example:
`SAS_TOKEN=<token> SQL_PASSWORD=<password> /path/to/backup.sh >> /var/log/librenms_backup.log 2>&1`

- Set `SAS_TOKEN` to the sas token of the credentials you are using to upload to azure
- Set `SQL_PASSWORD` to the password of the mariadb database. It is in vaultwarden

For the SAS token, I got it by going to the `scnbackups` storage account, in the left pannel under `Security + networking` go to `Shared access signature`. [link](https://portal.azure.com/#@seattlecommunitynetwork.onmicrosoft.com/resource/subscriptions/7f3f600b-c0c2-4c35-bf3a-e0b1cadfce71/resourceGroups/othello/providers/Microsoft.Storage/storageAccounts/scnbackups/sas) There you can create a shared access signature.
- I think for the allowed resource types you just need to select object
- I think for the allowed permissions you just need to  put `Write`
- You should be able to put the allowed IPs
- You can disable deletion of versions
- Set the expiration date and time to some time you are comfortable with and create a new one when it expires

When you generate it there is a field called `SAS token`

One thing this does not do is stop the service before backing up the db which it should probably do or else data may be corrupted
