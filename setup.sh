#!/bin/bash

#Add the nfs tools. 
#Create the drive
apt-get install nfs-common

if [ ! -d /mnt/observe ] 
then
	mkdir /mnt/observe
fi 

echo "Mounting drive"

#Mount the drive
if [ ! -d /mnt/observe/backups ] 
then
	echo "Drive not mounted. Mounting...."
	mount -t nfs files.byu.edu:ObservationSystems /mnt/observe
fi

echo "Creating backup directoris"
#Create our backup directories
if [ ! -d /mnt/observe/backups/$HOSTNAME ] 
then
	mkdir /mnt/observe/backups/$HOSTNAME
fi

if [ ! -d /mnt/observe/backups/$HOSTNAME/www ] 
then
mkdir /mnt/observe/backups/$HOSTNAME/www
fi

if [ ! -d /mnt/observe/backups/$HOSTNAME/content ] 
then
mkdir /mnt/observe/backups/$HOSTNAME/content
fi

echo "Getting backup script"
if [ ! -f /usr/sbin/backups/nightly.sh ] 
then
	mkdir /usr/sbin/backups
	cp /mnt/observe/scripts/nightly.sh /usr/sbin/backups
fi

echo "Creating cronjob"
#check if job exists 
if crontab -l | grep -q '/usr/sbin/backups/nightly.sh' ; then 
	echo "Cronjob already created."
else
	(crontab -l 2>/dev/null; echo "00 00 * * * /usr/sbin/backups/nightly.sh") | crontab -
fi

