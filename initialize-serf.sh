#!/bin/bash

LOG=/var/log/all
touch $LOG

if [ $1 = "--mongodb-events" ]; then
    serf agent -log-level=debug -event-handler=/etc/serf/scripts/mongodb_handler.sh >> $LOG &
else
    serf agent -log-level=debug -event-handler=/etc/serf/scripts/event_handler.sh >> $LOG &
fi


sleep 2

serf join $AD_PORT_7946_TCP_ADDR:$AD_PORT_7946_TCP_PORT
sleep 2
