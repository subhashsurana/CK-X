#!/bin/bash
kubectl create namespace services --dry-run=client -o yaml | kubectl apply -f -
kubectl create deployment public-web -n services --image=nginx:1.27 --replicas=2 --dry-run=client -o yaml | kubectl apply -f -
echo "Q8 setup complete"
