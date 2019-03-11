#!/bin/bash

docker service create --replicas 1 --name my-prometheus \
    --mount type=bind,source=${PWD}/override/prometheus.yml,destination=/etc/prometheus/prometheus.yml \
    --publish published=9090,target=9090,protocol=tcp \
    prom/prometheus