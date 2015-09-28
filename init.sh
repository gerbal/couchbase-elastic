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

wait_for_start couchbase-cli cluster-init -c 127.0.0.1:8091 -u $ADMIN_LOGIN -p $ADMIN_PASSWORD --cluster-init-username=${ADMIN_LOGIN} --cluster-init-password=${ADMIN_PASSWORD} --cluster-init-port=8091 --cluster-init-ramsize=${CLUSTER_RAM_QUOTA}

wait_for_start couchbase-cli bucket-create --cluster=127.0.0.1 -u $ADMIN_LOGIN -p $ADMIN_PASSWORD --bucket=data --bucket-type=couchbase --bucket-ramsize=512 --wait

wait_for_start couchbase-cli setting-xdcr -c localhost:8091 -u $ADMIN_LOGIN -p $ADMIN_PASSWORD --max-concurrent-reps=8
wait_for_start couchbase-cli xdcr-setup -c localhost:8091 -u $ADMIN_LOGIN -p $ADMIN_PASSWORD \
    --create \
    --xdcr-cluster-name=ElasticCouchbase \
    --xdcr-hostname=elastic-couchbase:9091 \
    --xdcr-username=$ADMIN_LOGIN \
    --xdcr-password=$ADMIN_PASSWORD
wait_for_start couchbase-cli xdcr-replicate -c localhost:8091 -u $ADMIN_LOGIN -p $ADMIN_PASSWORD \
    --xdcr-cluster-name=ElasticCouchbase \
    --xdcr-from-bucket=data \
    --xdcr-to-bucket=data \
	--xdcr-replication-mode=capi
wait



