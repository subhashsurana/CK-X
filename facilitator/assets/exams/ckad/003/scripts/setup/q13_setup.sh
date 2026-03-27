#!/bin/bash
kubectl create ns q13-storage
cat << 'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: library
  namespace: q13-storage
spec:
  replicas: 1
  selector:
    matchLabels:
      app: library
  template:
    metadata:
      labels:
        app: library
    spec:
      containers:
      - name: nginx
        image: nginx
        volumeMounts:
        - name: data-vol
          mountPath: /data
      volumes:
      - name: data-vol
        emptyDir: {}
EOF
