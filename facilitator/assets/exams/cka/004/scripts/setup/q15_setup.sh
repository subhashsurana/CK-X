#!/bin/bash
kubectl create namespace governance --dry-run=client -o yaml | kubectl apply -f -
echo "Q15 setup complete"
