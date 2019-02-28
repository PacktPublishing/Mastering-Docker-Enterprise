#!/bin/bash
#Generate Certificates
mkdir certs
openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key -x509 -days 365 -out certs/domain.crt
#Store Certificates as Secrets
docker secret create revprox_cert certs/domain.crt
docker secret create revprox_key certs/domain.key

# ----- Sample values -------
# Country Name (2 letter code) [AU]:US
# State or Province Name (full name) [Some-State]:Illinois
# Locality Name (eg, city) []:Chicago
# Organization Name (eg, company) [Internet Widgits Pty Ltd]:mydomain.com
# Organizational Unit Name (eg, section) []:test
# Common Name (e.g. server FQDN or YOUR name) []:at-sea.mydomain.com
# Email Address []:mpanthofer@mydomain.com