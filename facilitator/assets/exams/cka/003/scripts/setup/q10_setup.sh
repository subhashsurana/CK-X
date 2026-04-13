#!/bin/bash
kubectl create namespace troubleshooting --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: broken-web
  namespace: troubleshooting
spec:
  replicas: 2
  selector:
    matchLabels:
      app: broken-web
  template:
    metadata:
      labels:
        app: broken-web
    spec:
      containers:
      - name: web
        image: nginx:broken
EOF
echo "Q10 setup complete — broken-web deployment created with an invalid image"
