#!/bin/sh
[ $(curl --silent http://appserver:8080/index.html | grep -c "Atsea Shop") == "1" ] || exit 1