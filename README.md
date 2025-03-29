Backs up librenms to azure. It is meant to run from the librenms server

example:
`SAS_TOKEN=<token> SQL_PASSWORD=<password> /path/to/backup.sh >> /var/log/librenms_backup.log 2>&1`

- Set `SAS_TOKEN` to the sas token of the credentials you are using to upload to azure
- Set `SQL_PASSWORD` to the password of the mariadb database. It is in vaultwarden

For the SAS token, I got it by going to the `scnbackups` storage account, in the left pannel under `Security + privacy` go to `Shared access signature`. There you can create an SAS. When you generate it there is a field called `SAS token`, copy it. Also note the end time that the token is good for, make sure to check back on it when the token expires to create a new one

One thing this does not do is stop the service before backing up the db which it should probably do or else data may be corrupted
