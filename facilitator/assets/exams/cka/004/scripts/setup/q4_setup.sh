#!/bin/bash
kubectl create namespace logging --dry-run=client -o yaml | kubectl apply -f -
echo "Q4 setup complete"
