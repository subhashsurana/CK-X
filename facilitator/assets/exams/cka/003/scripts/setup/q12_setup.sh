#!/bin/bash
kubectl create namespace test --dry-run=client -o yaml | kubectl apply -f -
echo "Q12 setup complete — test namespace ready"
