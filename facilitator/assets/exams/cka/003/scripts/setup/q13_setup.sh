#!/bin/bash
kubectl create namespace restricted --dry-run=client -o yaml | kubectl apply -f -
echo "Q13 setup complete — restricted namespace ready"
