#!/bin/bash
## Example:
#./build_minions.sh 5 testinstance

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo "run script like:"
    echo "./build_minions.sh 5 testinstance"
    exit
fi

echo openstack_8gb: > cloud.map
#TODO: clean out all existing keys listed via:
# salt-key -L

for i in `seq 1 $1`; do
    printf "    - %s-%02d\n" ${2} ${i} >> cloud.map
done

echo "${2}" > minion_name

# possible replacement:
# service salt-master stop && service salt-master start
pkill salt-master && salt-master -d

# echo start time of instancing event
echo "${2}" >> stats
echo date >> stats

## Deploy instances
yes | sudo salt-cloud -P -m cloud.map -l all

# echo finish time of instancing
echo date >> stats

# write out configs for general usage / parsing
salt '*' network.ip_addrs --out=json --static > minion_metadata.json



# once the mpi list is built out pull it onto all the minions
#salt '*' state.highstate -l debug

## test connectivity
# salt '*' test.ping

## run remote commands
# salt '*' cmd.run 'uname -a'

## install dependencies
salt '*' state.highstate -l all
#salt-call -l debug state.highstate


