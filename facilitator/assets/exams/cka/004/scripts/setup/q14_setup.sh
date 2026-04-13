#!/bin/bash
kubectl create namespace storage --dry-run=client -o yaml | kubectl apply -f -
echo "Q14 setup complete"
