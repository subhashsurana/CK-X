#!/bin/bash
kubectl create namespace availability --dry-run=client -o yaml | kubectl apply -f -
kubectl create deployment api -n availability --image=nginx:1.27 --replicas=3 --dry-run=client -o yaml | kubectl apply -f -
echo "Q11 setup complete"
