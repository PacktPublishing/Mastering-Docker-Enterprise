#!/bin/bash

# Add your code to fetch and populate ./secrets/test ./secrets/prod using copy or vault etc.

# Set stack name
if [[ -z "$1" ]]; then
    echo "Usage: please specify dev, test or prod";
    exit 1;
else
    export STACK_ENV=$1
    export STACK=atsea-deployer-${STACK_ENV}
    export DTR_SERVER="dtr.mydomain.com"
fi

# Should fail and continue locally, but actually load the builder bundle in CI build
IFS=
eval $(<env.sh)

echo -e "Launching stack... docker stack deploy -c docker-stack-cluster.yml ${STACK} \n"
docker stack deploy -c docker-stack-cluster.yml ${STACK}