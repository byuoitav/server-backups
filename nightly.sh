#!/bin/bash

# directories to backup
# for each directory to be backed up you must add an output directory,
ODIR=(
/mnt/observe/backups/$HOSTNAME/content
/mnt/observe/backups/$HOSTNAME/www)

BDIR=(
/usr/local/WowzaStreamingEngine/content
/var/www/v3)

LOGDIR=/usr/sbin/backups/logs

ELKADDR=http://avmetrics.byu.edu/backups/observation
########################################################################


DATE=`date +%Y-%m-%dT%H:%M:%S%z`


curl -X POST -d '{"timestamp"':'"'$DATE'"','"hostname"':'"'$HOSTNAME'"','"event"':'"Starting Backup"}' $ELKADDR

# Check for stale file handle
statresult=`stat /mnt/observe 2>&1 | grep -i "stale"`
if [ "${statresult}" != "" ]; then
	umount -f /mnt/observe
	mount mount -t nfs files.byu.edu:ObservationSystems /mnt/observe
	
	#check for stale mount again - if it's still bad, report an error. 
	statresult=`stat /mnt/observe 2>&1 | grep -i "stale"`

	if [ "${statresult}" != "" ]; then
		#Report to ELKi

		DATE=`date +%Y-%m-%dT%H:%M:%S%z`

		curl -X POST -d '{"timestamp"':'"'$DATE'"','"hostname"':'"'$HOSTNAME'"','"event"':'"Stale File Handle"}' $ELKADDR
		exit -1
	fi
fi

if [ ! -d $LOGDIR ]
then
	mkdir $LOGDIR
fi

if [ ${#BDIR[@]} -ne ${#ODIR[@]} ];
then
	exit -1
fi	

BACKUPDIR=`date +%Y-%m-%d:%H:%M:%S`

export PATH=$PATH:/bin:/usr/bin:/usr/local/bin
VAR=0

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
      	rsync $OPTS $P ${ODIR[$var]}/current >> $LOGDIR/$BACKUPDIR.txt
	echo "" >> $LOGDIR/$BACKUPDIR.txt
	
	((var++))      	
done


DATE=`date +%Y-%m-%dT%H:%M:%S%z`

curl -X POST -d '{"timestamp"':'"'$DATE'"','"hostname"':'"'$HOSTNAME'"','"event"':'"Backup Completed."}' $ELKADDR

