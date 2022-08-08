Author: Gerald Lim Wee Koon (github: mathscantor)

Before the running the script, please adjust tihe following 

Important Parameters to set

```text
Parameters    		Description
----------		-----------
SOURCE_DIR    		Contains the source ip and the directory that you want to backup from. In the above script’s case, our source IP is our dedicated admin link to storage.csnet.lan and /tank is the                         parent directory which contains other sub directories that I want to backup.

BACKUP_DIR    		The directory that will store our backups. Preferably stored under a directory that is owned by root. This is so that chroot environment would work later on when users SFTP in.

LOG_DIR      		The directory that contains our script logs. Useful for debugging and seeing if anything went wrong during the automated backups.

INCLUDELIST_PATH  	Specify which files/directories you want to include in the backup.

EXCLUDELIST_PATH  	Specify which files you want to exclude in the backup

retention    		Specify how many backups we want to keep in BACKUP_DIR
```

Usage: ./create_new_backup.sh

Upon running the script, rsync will start. There will not be much output on the terminal. For more verbose logs, check under /home/root/rsync_logs.

Command: less -Rr YYYY-MM-DD_hh:mm:ss.log
OR
Command: cat YYYY-MM-DD_hh:mm:ss.log

Both commands will replay the log output as there is a special ^M character at the end of each verbose line
