#!/bin/bash
# Q1 Setup: Create a CrashLoopBackOff pod that needs a ConfigMap mount
kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: app-frontend
  namespace: production
    spec:
      nodeSelector:
        kubernetes.io/hostname: k3d-cluster-agent-0
      containers:
      - name: app
        image: busybox:1.36
        command: ["sh", "-c", "cat /etc/app/config.yaml && sleep 3600"]
EOF
echo "Q1 setup complete — app-frontend pod created in production (will CrashLoop until ConfigMap mounted)"
