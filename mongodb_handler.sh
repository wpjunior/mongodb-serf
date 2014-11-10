#!/bin/bash

while read line; do
    name=`echo $line | cut -f1 -d$' '`
    address=`echo $line | cut -f2 -d$' '`

    case ${SERF_EVENT} in
        "member-join")
            sed  "/${name}/d" /etc/hosts > /tmp/serf_hosts
            cp -Rf /tmp/serf_hosts /etc/hosts
            echo -e -n "${address}\t${name}\n" >> /etc/hosts;
            mongodb-cluster-join.sh $name &> /dev/null &
            ;;

        "member-leave")
            sed  "/${name}/d" /etc/hosts > /tmp/serf_hosts
            cp -Rf /tmp/serf_hosts /etc/hosts
            echo -e -n "${address}\t${name}\n" >> /etc/hosts;
            ;;
    esac
done
