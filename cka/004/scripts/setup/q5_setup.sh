#!/bin/bash
kubectl create namespace troubleshooting --dry-run=client -o yaml | kubectl apply -f -
kubectl create deployment api-server -n troubleshooting --image=nginx:1.27 --replicas=2 --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: api-service
  namespace: troubleshooting
spec:
  selector:
    app: wrong-api
  ports:
  - port: 80
    targetPort: 80
EOF
echo "Q5 setup complete"
