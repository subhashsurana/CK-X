#!/bin/bash
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
echo "Q6 setup complete — monitoring namespace ready, install helm chart manually"
