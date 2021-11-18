# borg_backup  

A script to automate borg backups.
Based on the script found here: https://borgbackup.readthedocs.io/en/stable/quickstart.html

## Email
The script attempts to send email alerts if the backup fails. You must configure postfix to send emails from your system for this to work.

## Variables
You must edit the following variables in the script.

**REPO** - The target borg repository. Can be a local directory, or remote (SSH)
SSH targets are in the format:

```
ssh://username@host:/path/to/repo
```

**BORG_PASSPHRASE** - passphrase for the target borg repository

**dest_addr** - destination email address to send alerts to, e.g. me@mydomain.com 

**daily** - number of daily backups to keep

**weekly** - number of weekly backups to keep

**montlhy** - number of monthly backups to keep

## Using cron

Make sure the script is in a good location and is marked executable.

```
chmod a+x /usr/bin/borg_backup
```

Also make sure to run the script manually first as a test. The script must run without any intervention to work with cron (i.e. no need to enter passphrases, etc).

Here is a sample cron entry to run the script at 1AM every day, logging to the file /var/log/borg_backup.log

```
1 * * * * /usr/bin/borg_backup >> /var/log/borg_backup.log
```

## logrotate
You should configure logrotate to rotate the log file. See the logrotate_sample file for an example.

Place the logrotate config file into /etc/logrotate.d. Make sure permissions are 644 and the owner is root:

```
cp logrotate_sample /etc/logrotate.d/borg_backup
chown root:root /etc/logrotate.d/borg_backup
chmod 644 /etc/logrotate.d/borg_backup
