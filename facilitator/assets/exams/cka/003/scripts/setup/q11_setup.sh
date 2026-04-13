#!/bin/bash
kubectl create namespace databases --dry-run=client -o yaml | kubectl apply -f -
echo "Q11 setup complete — databases namespace ready"
