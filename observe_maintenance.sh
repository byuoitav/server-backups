#!/bin/bash

# Script - Checks to see if Wowza is writing files after hours
# This will restart Wowza Streaming Engine if it finds files open 
# Set this up with Cron to function after hours with root user access
#
#

LOGDIR = /

LOGNAME =`date +%Y-%m-%d:%H:%M:%S` 

ODIR = \/usr\/local\/Wowza.*\/content\/valt_recordings\/video\/.*\/*.tmp

##################################################################
WOWZAOPEN=lsof | grep $ODIR

if [${WOWZAOPEN} != ""]; then
	echo 
else
	echo "No current files are open by Wowza.  Logging out information."  >> 
fi

