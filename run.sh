#!/bin/bash

LOG=/var/log/all
/usr/bin/mongo$OPTIONS >> $LOG &
/usr/sbin/sshd -D &
: "${OPTIONS:=}" # Mongo opptions

# Start mongo and log
echo $OPTIONS
sleep 3
initialize-serf.sh
tail -f $LOG
