#!/usr/bin/env sh

############################################################################################################################################################
# This shell script creates the Prometheus Nginx user account and then starts the Nginx server.
# The password for the user account can be passed in one of two environment variables:
#
#   1. PROMETHEUS_PASSWORD
#      This is not secure for Docker Swarm.
#
#      For Kubernetes you can create a Kubernetes secret with the password and configure the Kubernetes Manifest to set the environment variable when
#      the container is deployed.
#
#   2. PROMETHEUS_PASSWORD_FILE
#      This is the recommended method for Docker Swarm.  Create a docker secret and then pass the name of the secret file in this environment variable.
#      You can also use this method for Kubernetes. Create a Kubernetes secret and then pass the name of the secret file in this environment varriable.
#
############################################################################################################################################################
#
############################################################################################################################################################
# Gary Forghetti
# Docker, Inc
############################################################################################################################################################

set -e

if [ ! -z "${PROMETHEUS_PASSWORD}" ]; then
    echo "${PROMETHEUS_PASSWORD}" | htpasswd -im -c '/etc/nginx/.htpasswd' prometheus
elif [ ! -z "${PROMETHEUS_PASSWORD_FILE}" ]; then
    if [ -f "${PROMETHEUS_PASSWORD_FILE}" ]; then
        cat "${PROMETHEUS_PASSWORD_FILE}" | htpasswd -im -c '/etc/nginx/.htpasswd' prometheus
    else
        printf 'The PROMETHEUS_PASSWORD_FILE: %s does not exist!\n' "${PROMETHEUS_PASSWORD_FILE}" 
        exit 1
    fi        
fi         

exec nginx -g "daemon off;"
