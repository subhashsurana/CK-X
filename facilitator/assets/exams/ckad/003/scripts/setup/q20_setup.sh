#!/bin/bash
kubectl create ns q20-debug
cat << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: broken-logger
  namespace: q20-debug
spec:
  restartPolicy: Always
  containers:
  - name: app
    image: busybox
    command:
    - sh
    - -c
    - echo "FATAL: cache backend unavailable" && exit 1
EOF
