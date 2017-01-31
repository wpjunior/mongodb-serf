#!/bin/bash

hostname=$1
LOG=/var/log/all

echo "Start mongo event for" $1 "Suffix:" $MONGODB_SUFFIX >> $LOG


echo $hostname | grep -q '^rs'
if [ $? == 0 ]; then
    # setup replica set
    (
        flock -x -w 60 200 || exit 1
        rs_number=`echo $hostname | sed 's|^rs||g;s|db.*||g'`
        db_number=`echo $hostname | sed 's|\..*||g;s|.*db||g'`

        if [ $db_number == 01 ]; then
            echo "Start initializing the replicaset" $hostname
            mongo ${hostname}:27017/admin --eval "JSON.stringify(rs.initiate());" >> $LOG 2>&1
            sleep 5
            echo "Start add the created replicaset into sharding" $hostname
            mongo router01.${MONGODB_SUFFIX}:27017/admin --eval "JSON.stringify(sh.addShard('rs${rs_number}/${hostname}:27017'))" >> $LOG 2>&1
            sleep 2
        else
            echo "Start add the host into replicaset" $hostname
            primary="rs${rs_number}db01.${MONGODB_SUFFIX}"
            mongo ${primary}:27017/admin --eval "JSON.stringify(rs.add('$hostname:27017'))" >> $LOG 2>&1
        fi

    ) 200>/var/lock/.mongodb-cluster.lock
fi

echo $hostname | grep -q '^configserver01'
if [ $? == 0 ]; then
    echo "Setup config server replicaset" >> $LOG
    sleep 5
    mongo ${hostname}:27019/admin --eval "JSON.stringify(rs.initiate({_id: 'cfg', configsvr: true, members: [{_id:0, host:'configserver01.${MONGODB_SUFFIX}:27019'}, {_id:1, host:'configserver02.${MONGODB_SUFFIX}:27019'}, {_id: 2, host: 'configserver03.${MONGODB_SUFFIX}:27019'}]}));" >> $LOG 2>&1
fi
