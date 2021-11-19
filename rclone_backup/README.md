# rclone backup  

A script to automate rclone backups. Not affiliated with rclone or rclone_jobber devs in any way.

Review the main rclone docs at https://rclone.org/docs/

## Email
The script attempts to send email alerts if the backup fails. You must configure postfix to send emails from your system for this to work.

## Variables
You must edit the following variables in the script.


**source** - Source to back up. Can be a local directory, or an rclone remote (must configure first with rclone config)

**dest** - Destination to back up to. Can be a local directory, or an rclone remote (must configure first with rclone config)

**dest_addr** - destination email address to send alerts to, e.g. me@mydomain.com 

**bandwidth_limit** - Uses bytes, not bits! This can be a fixed limit, or set to change on a schedule. See the rclone docs for details. Default of 0 means no limit.

**options** - Any other rclone options you want to pass to rclone.

## Using cron

Make sure the script is in a good location and has proper permissions.

```
chmod 700 /root/bin/rclone_backup
```

Also make sure to run the script manually first as a test. The script must run without any intervention to work with cron (i.e. no need to enter passphrases, etc).

Here is a sample cron entry to run the script at 1AM every day, logging to the file /var/log/rclone_backup.log

```
* 1 * * * /root/bin/rclone_backup >> /var/log/rclone_backup.log 2>&1

```

## logrotate
You should configure logrotate to rotate the log file. See the logrotate_sample file for an example.

Place the logrotate config file into /etc/logrotate.d. Make sure permissions are 644 and the owner is root:

```
cp logrotate_sample /etc/logrotate.d/rclone_backup
chown root:root /etc/logrotate.d/rclone_backup
chmod 644 /etc/logrotate.d/rclone_backup
