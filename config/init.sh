#!/bin/bash

wait_for_start() {
    "$@"
    while [ $? -ne 0 ]
    do
        echo 'waiting for couchbase config to start'
        sleep 1
        "$@"
    done
}

wait_for_start couchbase-cli server-list -c couchbase -u $ADMIN_LOGIN -p $ADMIN_PASSWORD

if [ "$REBALANCE_CLUSTER" = "1" ]; then
    sleep 10
    wait_for_start couchbase-cli rebalance -c couchbase -u $ADMIN_LOGIN -p $ADMIN_PASSWORD
else
    
    couchbase-cli bucket-create -c couchbase -u $ADMIN_LOGIN -p $ADMIN_PASSWORD --bucket=data --bucket-type=couchbase --bucket-ramsize=256 --wait
    
    couchbase-cli bucket-create -c couchbase -u $ADMIN_LOGIN -p $ADMIN_PASSWORD --bucket=cache --bucket-type=memcached --bucket-ramsize=256 --wait

    couchbase-cli setting-xdcr -c couchbase -u $ADMIN_LOGIN -p $ADMIN_PASSWORD --max-concurrent-reps=8
    couchbase-cli xdcr-setup -c couchbase -u $ADMIN_LOGIN -p $ADMIN_PASSWORD \
            --create \
            --xdcr-cluster-name=ElasticCouchbase \
            --xdcr-hostname=elastic-couchbase:9091 \
            --xdcr-username=$ADMIN_LOGIN \
            --xdcr-password=$ADMIN_PASSWORD
    couchbase-cli xdcr-replicate -c couchbase -u $ADMIN_LOGIN -p $ADMIN_PASSWORD \
            --xdcr-cluster-name=ElasticCouchbase \
            --xdcr-from-bucket=data \
            --xdcr-to-bucket=data \
            --xdcr-replication-mode=capi
    
    wait_for_start couchbase-cli rebalance -c couchbase -u $ADMIN_LOGIN -p $ADMIN_PASSWORD    
fi
