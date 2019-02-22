#!/bin/bash

# Script - Checks to see if Wowza is writing files after hours
# This will restart Wowza Streaming Engine if it finds files open 
# Set this up with Cron to function after hours with root user access
#
#

LOGDIR=/usr/sbin/maintenance/logs

LOGNAME=`date +%Y-%m-%d:%H:%M:%S` 

ODIR=`\/usr\/local\/Wowza.*\/content\/valt_recordings\/video\/.*\/*.tmp`

##################################################################

export PATH=$PATH:/bin:/usr/bin:/usr/local/bin 

DATE=`date +%Y-%m-%dT%H:%M:%S%z`

# Make sure that the log path has already been created, if not create it


# Check to see if tmp files are open on the server in the Wowza content path
WOWZAOPEN=`lsof | grep $ODIR`

touch $LOGDIR/$LOGNAME.txt
echo "-----------------------------------------------" >> $LOGDIR/$LOGNAME.txt
echo "Observation System Maintenance Script"
echo "Run on: " >> $LOGDIR/$LOGNAME.txt 
$DATE >> $LOGDIR/$LOGNAME.txt 
echo "-----------------------------------------------" >> $LOGDIR/$LOGNAME.txt

# If there are open tmp files on the system, restart Wowza and check that Wowza is active
# Currently on the servers, we can't check using standard service check because it is broken
# We are going to check using the Wowza HTTP API to make sure that the service is running 
if [${WOWZAOPEN} != "" -a ${WOWZAOPEN} == *"java"*]; then
	echo "There are tmp files open....."  >> $LOGDIR/$LOGNAME.txt
	echo "Checking to see they are open by Wowza"  >> $LOGDIR/$LOGNAME.txt
	echo "------------------------------------------" >> $LOGDIR/$LOGNAME.txt 
	echo "Rebooting WowzaStreamingEngine"  >> $LOGDIR/$LOGNAME.txt
	# WOWZARESTART=`service WowzaStreamingEngine restart`
	echo $WOWZARESTART >> $LOGDIR/$LOGNAME.txt 
	sleep 30

	SERVICETEST=`curl localhost:1935`
	if [$SERVICETEST == *"Wowza Streaming"*]; then
		echo "Wowza reboot was successful"  >> $LOGDIR/$LOGNAME.txt
	else
		echo "Wowza reboot was unsuccessful"  >> $LOGDIR/$LOGNAME.txt
		echo "Attempting one more reboot of Wowza"  >> $LOGDIR/$LOGNAME.txt
		echo "--------------------------------------------" >> $LOGDIR/$LOGNAME.txt 
		# WOWZARESTART=`service WowzaStreamingEngine restart`
		echo $WOWZARESTART >> $LOGDIR/$LOGNAME.txt 
		sleep 30
		echo "" >> $LOGDIR/$LOGNAME.txt 
		echo "Checking Wowza Service"  >> $LOGDIR/$LOGNAME.txt
		SERVICETEST=`curl localhost:1935`
		if [$SERVICETEST == *"Wowza Streaming"*]; then
			echo "Wowza reboot was successful"  >> $LOGDIR/$LOGNAME.txt
		el 
			echo "Wowza reboot was unsuccessful"  >> $LOGDIR/$LOGNAME.txt
			echo "Please check on the server and the service"  >> $LOGDIR/$LOGNAME.txt
		fi
else
	echo "No current tmp files are open by Wowza"  >> $LOGDIR/$LOGNAME.txt
fi

