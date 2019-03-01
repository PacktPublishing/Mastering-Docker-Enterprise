#!/bin/bash

# Add your code to fetch and populate ./secrets/test ./secrets/prod using copy or vault etc.

# Set stack name
if [[ -z "$1" ]]; then
    echo "Usage: please specify dev, test or prod";
    exit 1;
else
    export STACK_ENV=$1
    export STACK=${STACK_ENV}_at-sea
fi

#echo STACK $(echo "$STACK")
#echo STACK_ENV $(echo "$STACK_ENV")

echo -e "Remove old stuff...\n"

# Clean up old external stuff
echo $(docker network rm front-tier)
echo $(docker secret rm wildcard.domaim.com.key)
echo $(docker secret rm wildcard.domaim.com.server.crt)
echo $(docker secret rm postgres_password)
echo $(docker secret rm payment_token)


echo -e "Waiting for 5 seconds...\n" $(sleep 5) "\n\n"
echo -e "Creating new external networks and certificates...\n"
echo -e $(docker network create -d overlay front-tier) "\n"
echo -e $(docker secret create wildcard.domaim.com.key ./secrets/${STACK_ENV}/wildcard.domaim.com.key) "\n"
echo -e $(docker secret create wildcard.domaim.com.server.crt ./secrets/${STACK_ENV}/wildcard.domaim.com.server.crt) "\n"
echo -e $(docker secret create postgres_password secrets/${STACK_ENV}/postgres_password) "\n"
echo -e $(docker secret create payment_token secrets/${STACK_ENV}/payment_token) "\n"

echo -e "Waiting for 5 seconds...\n" $(sleep 5) "\n"
echo -e "Launching stack..." $(docker stack deploy -c docker-stack-cluster.yml ${STACK}) "\n"