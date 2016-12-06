#!/bin/bash

# directories to backup
# for each directory to be backed up you must input an output directory,
ODIR=(
/mnt/observe/backups/$HOSTNAME/www
/mnt/observe/backups/$HOSTNAME/content)

BDIR=(
/usr/local/WowzaStreamingEngine/content
/var/www/v3)

########################################################################

if [ ${#BDIR[@]} -ne ${#ODIR[@]} ];
then
	exit -1
fi	

BACKUPDIR=`date +%Y-%m-%d:%H:%M:%S` 
OPTS="--force --delete --backup --backup-dir=$ODIR/incremental/$BACKUPDIR -avz"

export PATH=$PATH:/bin:/usr/bin:/usr/local/bin
VAR=0

for P in ${BDIR[@]}
do
	#echo $P
	echo ${ODIR[$var]}
      	# transfer
      	rsync $OPTS $P ${ODIR[$var]}/Current
	((var++))      	
done
