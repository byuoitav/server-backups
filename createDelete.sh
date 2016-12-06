#!/bin/bash

BaseFile='/home/sir/Documents/Work/serverBackup/test'

#Randomly delete four files
find $BaseFile -type f | shuf -n 4 | xargs rm -f 

#Randomly Create 5
for i in {1..5}
do
	echo $(date +%D-%r) >> $BaseFile/$RANDOM.txt
done

#Randomly edit some number between 1-10 

for f in $(find $BaseFile -type f | shuf -n $(shuf -n 1 -i 1-20))
do
	echo $f
	echo $(date +%D-%r) >> $f
done
