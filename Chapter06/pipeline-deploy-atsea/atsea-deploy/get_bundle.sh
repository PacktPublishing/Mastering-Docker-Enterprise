#!/bin/bash
export AUTH_TOKEN=$(curl -sk -d '{"username":"'${DEPLOYER_USER}'","password":"'${DEPLOYER_PW}'"}' https://ucp.mydomain.com/auth/login | jq -r .auth_token 2>/dev/null)
echo "Authtoken: ${AUTH_TOKEN}"
curl -sk -H "Authorization: Bearer ${AUTH_TOKEN}" https://ucp.mydomain.com/api/clientbundle -o bundle.zip
ls -la
unzip bundle.zip