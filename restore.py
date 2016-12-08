#!/usr/bin/python

import sys
import socket
import os
import datetime
import shutil

args = sys.argv[1:]

Hostname = socket.gethostname()
BackupDir = "/mnt/observe/backups/" + Hostname

if len(args != 3):
    print """
        Usage "serverBackup.py <Directory To Restore> <DirectoryToRestoreTo> <Date To Restore To>"
        Directory To Restore must be relative to one of the root directories found in /mnt/observe/backups/$HOSTNAME
        e.g. given the file system
          
          mnt
          |-observe
           |-backups
            |-$HOSTNAME
             |-content
             |-www

        The expected directory would be in the form of content/... or www/...
        
        DirectoryToRestoreTo is the directory in which to place the directory to restore     

        The date is expected in yyyy-mm-dd .abs
        """

DirToRestore = args[0]
DateToRestore = datetime.strptime(args[1], '%Y-%m-%d')
destDir = args[2]

#Get the listing of the directory, check and see if we can match it to some location in the directory
#to restore

rootBackupDirs = os.listdir(BackupDir)

parentDir = DirToRestore.split()

found = False
rootDir = ""

for d in rootBackupDirs:
    if parentDir[0] == d:
        found = true
        rootDir = d
        break

if (!found):
    print "Invalid backup path."
    return

#check if the time desired is today, if so, no backup will exist. 
if (DateToRestore == datetime.now().date()):
    print "There is no backup for today."
    return

#restore current, as that will be necessary
CopyCommand = "cp -R " + BackupDir + "/" + rootDir + "/current/" + DirToRestore + " " + destDir
print "Copying latest backup information"
os.system(CopyCommand)

print "Calculating the incrementals to copy"
#get all the date directories in the incremental directory
incrementalDateStrings = os.listdir(BackupDir + "/" + rootDir + "/incremental")
incrementalDates = []

fileDateFormat = '%Y-%m-%d:%H:%M:%S'

for incDate in incrementalDateStrings:
    incrementalDates.append(datetime.datetime.strptime(incDate, fileDateFormat))

incrementalDates.sort(reverse=true)
CopyCommand1 = "rsync " + BackupDir + "/" + rootDir + "/incremental/"
CopyCommand2 = " " + DirToRestore
#calculate how many dates we need to copy
for date in incrementalDates :
    if (date.date() > DateToRestore):
        print("Restoring date " + date.date())
        os.System(CopyCommand1 + "date/" + date.strftime(fileDateFormat) + "/" + DirToRestore + " " + DirToRestore)


print("done")
