#!/bin/bash
    docker run -d --name sysdig-agent \
    --restart always \
    --privileged \
    --net host \
    --pid host \
    -e ACCESS_KEY=b5bf2f12-08af-4c70-9884-c4c324b5e554 \
    -e SECURE=true \
    -e TAGS=example_tag:example_value \
    -v /var/run/docker.sock:/host/var/run/docker.sock \
    -v /dev:/host/dev \
    -v /proc:/host/proc:ro \
    -v /boot:/host/boot:ro \
    -v /lib/modules:/host/lib/modules:ro \
    -v /usr:/host/usr:ro \
    --shm-size=512m \
    sysdig/agent