#!/bin/bash
# Create a dedicated workload on k3d-cluster-agent-1 to drain.
kubectl label node k3d-cluster-agent-1 kubernetes.io/hostname=k3d-cluster-agent-1 --overwrite
kubectl taint node k3d-cluster-agent-1 maintenance=reserved:NoSchedule --overwrite

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: drain-test
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: drain-test
  template:
    metadata:
      labels:
        app: drain-test
    spec:
      nodeSelector:
        kubernetes.io/hostname: k3d-cluster-agent-1
      tolerations:
      - key: maintenance
        operator: Equal
        value: reserved
        effect: NoSchedule
      containers:
      - name: nginx
        image: nginx:1.27
EOF
echo "Q3 setup complete — drain-test deployment created"
