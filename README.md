Backs up librenms to azure. It is meant to run from the librenms server. Currently the sh script runs on ash, I did not try it on bash

example:
`SAS_TOKEN_FILE=<token_file> SQL_PASSWORD_FILE=<password_file> /path/to/backup.sh >> /var/log/librenms_backup.log 2>&1`

- Set `SAS_TOKEN` to the path of a file containing the sas token of the credentials you are using to upload to azure
- Set `SQL_PASSWORD` to the path of a file containing the password of the mariadb database. It is in vaultwarden

For the SAS token, I got it by going to the `scnbackups` storage account, in the left pannel under `Security + networking` go to `Shared access signature`. [link](https://portal.azure.com/#@seattlecommunitynetwork.onmicrosoft.com/resource/subscriptions/7f3f600b-c0c2-4c35-bf3a-e0b1cadfce71/resourceGroups/othello/providers/Microsoft.Storage/storageAccounts/scnbackups/sas) There you can create a shared access signature.
- For `Allowed services` you only need to have `Blob` checked
- For the `Allowed resource types` you just need to select `object`
- For the `Allowed permissions` you need to put `Write` and `Create`
- For `Blob versioning permissions` you can put that as unchecked
- For `Allowed blob index permissions` you just need to check `Read/Write` and leave `Filter` unchecked
- Set the expiration date and time to some time you are comfortable with and create a new one when it expires. Just make sure to take note of the expiration date because I dont think you can get it back after you go to another screen
- For allowed IPs, if you know the IP it is coming from I guess you can set it but I did not know so I did not set it

When you generate it there is a field called `SAS token`. Copy that one.


