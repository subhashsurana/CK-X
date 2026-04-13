#!/bin/bash
kubectl create namespace appconfig --dry-run=client -o yaml | kubectl apply -f -
kubectl create configmap app-config -n appconfig --from-literal=LOG_LEVEL=info --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: config-consumer
  namespace: appconfig
spec:
  replicas: 1
  selector:
    matchLabels:
      app: config-consumer
  template:
    metadata:
      labels:
        app: config-consumer
    spec:
      containers:
      - name: app
        image: busybox:1.36
        command: ["sh", "-c", "sleep 3600"]
        env:
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: LOG_LEVEL
EOF
echo "Q6 setup complete"
