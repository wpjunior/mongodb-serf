#!/bin/bash

LOG=/var/log/all
initialize-serf.sh --mongodb-events
tail -f $LOG
