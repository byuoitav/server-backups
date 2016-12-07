#!/bin/bash

# directories to backup
# for each directory to be backed up you must input an output directory,
ODIR=(
/mnt/observe/backups/$HOSTNAME/content
/mnt/observe/backups/$HOSTNAME/www)

BDIR=(
/usr/local/WowzaStreamingEngine/content
/var/www/v3)

LOGDIR=/usr/sbin/backups/logs
########################################################################

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
