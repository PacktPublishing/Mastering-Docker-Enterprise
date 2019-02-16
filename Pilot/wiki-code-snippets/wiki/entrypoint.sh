#!/bin/bash
while :
do
    echo "Probing postgres:5432 ..."
    nc -z -w 1 postgres 5432 </dev/null
    result=$?
    if [[ $result -eq 0 ]]; then
        echo "postgres is reachable!"
        break
    fi
    sleep 5
done

echo "starting tomcat catalina in 10 seconds..."
sleep 10
catalina.sh run