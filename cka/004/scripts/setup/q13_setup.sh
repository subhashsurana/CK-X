#!/bin/bash
kubectl create namespace restricted-ops --dry-run=client -o yaml | kubectl apply -f -
echo "Q13 setup complete"
