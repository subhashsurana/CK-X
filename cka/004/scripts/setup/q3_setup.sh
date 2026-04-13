#!/bin/bash
kubectl create namespace data --dry-run=client -o yaml | kubectl apply -f -
kubectl create deployment db-client -n data --image=busybox:1.36 --dry-run=client -o yaml -- sh -c 'sleep 3600' | kubectl apply -f -
echo "Q3 setup complete"
