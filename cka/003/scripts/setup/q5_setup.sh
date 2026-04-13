#!/bin/bash
kubectl create namespace shop --dry-run=client -o yaml | kubectl apply -f -
# Create sample pods with tier labels
for tier in frontend backend database; do
  kubectl run ${tier}-pod -n shop --image=nginx:1.27 --labels="tier=${tier}" --dry-run=client -o yaml | kubectl apply -f -
done
echo "Q5 setup complete — shop namespace with tier-labeled pods ready"
