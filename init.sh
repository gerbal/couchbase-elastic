#!/bin/bash

wait_for_start() {
    "$@"
    while [ $? -ne 0 ]
    do
        echo 'waiting for couchbase to start'
        sleep 1
        "$@"
    done
}

echo "launch couchbase"
/entrypoint.sh couchbase-server &

wait_for_start couchbase-cli server-info -c localhost:8091 -u $ADMIN_LOGIN -p $ADMIN_PASSWORD

if [ -n "${COUCHBASE_NAME:+1}" ]; then
    wait_for_start couchbase-cli server-list -c couchbase:8091 -u $ADMIN_LOGIN -p $ADMIN_PASSWORD
    
    ip=`hostname --ip-address`
    wait_for_start couchbase-cli server-add -c couchbase -u $ADMIN_LOGIN -p $ADMIN_PASSWORD --server-add=$ip:8091 --server-add-username=$ADMIN_LOGIN --server-add-password=$ADMIN_PASSWORD
else
    wait_for_start couchbase-cli cluster-init -c 127.0.0.1 -u $ADMIN_LOGIN -p $ADMIN_PASSWORD --cluster-init-username=${ADMIN_LOGIN} --cluster-init-password=${ADMIN_PASSWORD} --cluster-init-port=8091 --cluster-init-ramsize=${CLUSTER_RAM_QUOTA}
fi
        
wait



