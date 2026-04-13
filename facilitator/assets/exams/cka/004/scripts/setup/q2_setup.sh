#!/bin/bash
kubectl create namespace payments --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-api
  namespace: payments
spec:
  replicas: 2
  selector:
    matchLabels:
      app: payment-api
  template:
    metadata:
      labels:
        app: payment-api
    spec:
      containers:
      - name: app
        image: nginx:1.26
EOF
kubectl rollout status deployment/payment-api -n payments --timeout=60s >/dev/null 2>&1 || true
kubectl set image deployment/payment-api -n payments app=nginx:broken >/dev/null 2>&1 || true
echo "Q2 setup complete"
