#!/bin/bash

ZK_HOST="localhost"
ZK_PORT=2181
ZK_PATH_CONFIG="/opt/kafka_2.12-2.1.0/config/zookeeper.properties"

zk_servers="$(grep "server" $ZK_PATH_CONFIG |grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" )"
brokers_list="$(echo dump | nc $ZK_HOST $ZK_PORT | grep brokers)"
while [ -z "$brokers_list" ]
do
brokers_list="$(echo dump | nc $ZK_HOST $ZK_PORT | grep brokers)"
done


for i in  $brokers_list
do
    ip_broker=`bin/zookeeper-shell.sh "$ZK_HOST:$ZK_PORT" get $i 2>/dev/null | tail -n 1| grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | head -1`
#    ip_broker="$(echo $DETAIL | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | head -1)"
    alive_brokers="$ip_broker $alive_brokers"
done
#echo "broker list: $brokers_list"
#echo "current broker: $alive_brokers"
#echo "zk: $zk_servers"

for  ip in $zk_servers
do
    if ! grep -q $ip <<< $alive_brokers;  then
       down_hosts="$ip;$down_hosts"
    fi
done
if  ! [ -z "$down_hosts" ]
then
 echo "hosts down: $down_hosts"
fi
