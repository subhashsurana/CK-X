#!/bin/bash
kubectl create namespace databases --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db-app
  namespace: databases
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db-app
  template:
    metadata:
      labels:
        app: db-app
    spec:
      containers:
      - name: db
        image: busybox:1.36
        command: ["sleep", "3600"]
EOF
echo "Q4 setup complete — db-app deployment created in databases namespace"
