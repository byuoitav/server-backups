#!/bin/bash

# directories to backup
# for each directory to be backed up you must add an output directory
# These top ones will backup just the application and content folders
# use these only on Media servers and not on the main application server
#
source /etc/environment
BACKUPSERV=($BACKUP_SERVER_NAME)

BACKUPUSER=($BACKUP_USERNAME)

ODIR=(
/mnt/backups/octoprint/$HOSTNAME/.octoprint
/mnt/backups/octoprint/$HOSTNAME/OctoPrint
/mnt/backups/octoprint/$HOSTNAME/uploads)

BDIR=(
/home/pi/.octoprint
/home/pi/OctoPrint
/home/pi/uploads)

LOGDIR=/usr/sbin/backups/logs

# Number of days to retain backups
RETDAYS=60

#SLACK=$SLACK_POST
########################################################################


DATE=`date +%Y-%m-%dT%H:%M:%S%z`

if [ ${#BDIR[@]} -ne ${#ODIR[@]} ];
then
	exit -1
fi	

if [ ! -d $LOGDIR ]
then
	mkdir $LOGDIR
fi

BACKUPDIR=`date +%Y-%m-%d:%H:%M:%S`

export PATH=$PATH:/bin:/usr/bin:/usr/local/bin
VAR=0

# Backup files and Archive deleted files in incremental folder
for P in ${BDIR[@]}
do
	INCREMENTALDIR=${ODIR[$var]}/incremental/$BACKUPDIR
	OPTS="--force --delete --backup --backup-dir=$INCREMENTALDIR -avz"

	#echo $P
	echo ${ODIR[$var]}
	echo "-------------$P >> ${ODIR[$var]}/current--------------" >> $LOGDIR/$BACKUPDIR.txt
	echo "-------------Inrementals >> $INCREMENTALDIR ----------------" >> $LOGDIR/$BACKUPDIR.txt
	echo "" >> $LOGDIR/$BACKUPDIR.txt

      	# transfer
      	rsync $OPTS $P $BACKUPUSER@$BACKUPSERV:${ODIR[$var]}/current >> $LOGDIR/$BACKUPDIR.txt
	echo "" >> $LOGDIR/$BACKUPDIR.txt
	
	((var++))      	
done

DATE=`date +%Y-%m-%dT%H:%M:%S%z`

