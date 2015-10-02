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

# wait for couchbase to be up
wait_for_start couchbase-cli server-info -c localhost:8091 -u $ADMIN_LOGIN -p $ADMIN_PASSWORD

# if this node should reach an existing server (a couchbase link is defined)
if [ -n "${COUCHBASE_NAME:+1}" ]; then
    # wait for couchbase clustering to be setup
    wait_for_start couchbase-cli server-list -c couchbase:8091 -u $ADMIN_LOGIN -p $ADMIN_PASSWORD
    
    # add this new node to the cluster
    ip=`hostname --ip-address`
    couchbase-cli server-add -c couchbase -u $ADMIN_LOGIN -p $ADMIN_PASSWORD --server-add=$ip:8091 --server-add-username=$ADMIN_LOGIN --server-add-password=$ADMIN_PASSWORD
else
    # init the cluster
    couchbase-cli cluster-init -c 127.0.0.1 -u $ADMIN_LOGIN -p $ADMIN_PASSWORD --cluster-init-username=${ADMIN_LOGIN} --cluster-init-password=${ADMIN_PASSWORD} --cluster-init-port=8091 --cluster-init-ramsize=${CLUSTER_RAM_QUOTA}
    
    # create bucket data
    couchbase-cli bucket-create -c 127.0.0.1 -u $ADMIN_LOGIN -p $ADMIN_PASSWORD --bucket=data --bucket-type=couchbase --bucket-ramsize=256 --wait
    
    #create bucket cache
    couchbase-cli bucket-create -c 127.0.0.1 -u $ADMIN_LOGIN -p $ADMIN_PASSWORD --bucket=cache --bucket-type=memcached --bucket-ramsize=256 --wait

    # configure and launch xdcr to sync with elastic
    couchbase-cli setting-xdcr -c 127.0.0.1 -u $ADMIN_LOGIN -p $ADMIN_PASSWORD --max-concurrent-reps=8
    couchbase-cli xdcr-setup -c 127.0.0.1 -u $ADMIN_LOGIN -p $ADMIN_PASSWORD \
            --create \
            --xdcr-cluster-name=ElasticCouchbase \
            --xdcr-hostname=elastic-couchbase:9091 \
            --xdcr-username=$ADMIN_LOGIN \
            --xdcr-password=$ADMIN_PASSWORD
    couchbase-cli xdcr-replicate -c 127.0.0.1 -u $ADMIN_LOGIN -p $ADMIN_PASSWORD \
            --xdcr-cluster-name=ElasticCouchbase \
            --xdcr-from-bucket=data \
            --xdcr-to-bucket=data \
            --xdcr-replication-mode=capi
    
    # wait for other node to connect to the cluster
    sleep 5
    
    # rebalance
    couchbase-cli rebalance -c 127.0.0.1 -u $ADMIN_LOGIN -p $ADMIN_PASSWORD    
fi
        
wait



