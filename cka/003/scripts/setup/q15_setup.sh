#!/bin/bash
mkdir -p /opt
kubectl create namespace backup-task --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-settings
  namespace: backup-task
data:
  mode: production
  retries: "3"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backup-app
  namespace: backup-task
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backup-app
  template:
    metadata:
      labels:
        app: backup-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
EOF
echo "Q15 setup complete — backup-task namespace resources created"
