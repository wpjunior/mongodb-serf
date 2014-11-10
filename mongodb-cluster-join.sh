#!/bin/bash

set -e

hostname=$1
LOG=/var/log/all


echo $hostname | grep -q '^rs'
if [ $? == 0 ]; then
    # setup replica set
    (
        flock -x -w 60 200 || exit 1
        rs_number=`echo $hostname | sed 's|^rs||g;s|db.*||g'`
        db_number=`echo $hostname | sed 's|\..*||g;s|.*db||g'`

        if [ $db_number == 01 ]; then
            mongo ${hostname}:27017/test --eval "JSON.stringify(rs.initiate());" >> $LOG
            sleep 5
            mongo router01:27017/test --eval "JSON.stringify(sh.addShard('rs${rs_number}/${hostname}:27017'))" >> $LOG
            sleep 2
        else
            primary="rs${rs_number}db01"
            mongo ${primary}:27017/test --eval "JSON.stringify(rs.add('$hostname:27017'))" >> $LOG
        fi

    ) 200>/var/lock/.mongodb-cluster.lock
fi
