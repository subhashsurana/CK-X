#!/bin/bash
kubectl create namespace platform --dry-run=client -o yaml | kubectl apply -f -
echo "Q12 setup complete"
