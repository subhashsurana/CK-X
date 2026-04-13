#!/bin/bash
kubectl create namespace frontend --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace backend --dry-run=client -o yaml | kubectl apply -f -
kubectl create deployment web-ui -n frontend --image=nginx:1.27 --replicas=1 --dry-run=client -o yaml | kubectl apply -f -
kubectl expose deployment web-ui -n frontend --port=80 --target-port=80 --dry-run=client -o yaml | kubectl apply -f -
echo "Q1 setup complete"
