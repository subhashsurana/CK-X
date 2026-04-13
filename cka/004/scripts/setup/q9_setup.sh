#!/bin/bash
kubectl create namespace batch --dry-run=client -o yaml | kubectl apply -f -
echo "Q9 setup complete"
