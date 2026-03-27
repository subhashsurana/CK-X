#!/bin/bash
kubectl create ns q5-kustomize
mkdir -p /tmp/kustomize-base
cat << 'EOF' > /tmp/kustomize-base/kustomization.yaml
resources:
- deployment.yaml
EOF
cat << 'EOF' > /tmp/kustomize-base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx
EOF
