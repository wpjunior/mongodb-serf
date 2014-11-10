#!/bin/bash

LOG=/var/log/all
initialize-serf.sh --mongodb-events
/usr/sbin/sshd -D &
tail -f $LOG
