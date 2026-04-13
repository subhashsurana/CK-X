#!/bin/bash
# Create api service and TLS secret for ingress question
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: api
  namespace: default
spec:
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: v1
kind: Secret
metadata:
  name: api-tls-cert
  namespace: default
type: kubernetes.io/tls
data:
  tls.crt: $(echo -n "placeholder-cert" | base64)
  tls.key: $(echo -n "placeholder-key" | base64)
EOF
echo "Q9 setup complete — api service and TLS secret created"
