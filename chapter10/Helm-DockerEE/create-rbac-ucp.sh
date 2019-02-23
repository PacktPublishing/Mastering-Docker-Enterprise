#!/bin/bash
kubectl create rolebinding default-view --clusterrole=view --serviceaccount=kube-system:default --namespace=kube-system
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default