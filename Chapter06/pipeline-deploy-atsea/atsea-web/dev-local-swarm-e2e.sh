#!/bin/bash
export CI_COMMIT_REF_NAME="mpanthofer-local-dev"
#docker-compose -f docker-compose-build.yml build
docker stack deploy --with-registry-auth -c docker-compose-e2e.yml atsea-web-${CI_COMMIT_REF_NAME}
sleep 3
docker container run --network atsea-web-${CI_COMMIT_REF_NAME}_front-tier --rm local-test-driver:temp
#docker container run --network atsea-web-${CI_COMMIT_REF_NAME}_front-tier --rm alpine:3.7 apk ./
#docker container run --network atsea-web-${CI_COMMIT_REF_NAME}_front-tier --rm -it alpine:3.7 apk add curl && curl --silent 'http://appserver:8080/index.html' 