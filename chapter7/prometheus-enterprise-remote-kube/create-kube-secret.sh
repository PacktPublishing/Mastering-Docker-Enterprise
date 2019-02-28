#!/bin/bash
kubectl create secret generic prometheus --from-file=/c/Users/ntc-dev/ntc-prod/cli-admin/ca.pem \
--from-file=/c/Users/ntc-dev/ntc-prod/cli-admin/cert.pem \
--from-file=/c/Users/ntc-dev/ntc-prod/cli-admin/key.pem