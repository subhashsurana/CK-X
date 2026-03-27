#!/bin/bash
# Q2 Step 3: Verify Pod has env var APP_PORT from configMapKeyRef and volume mount at /etc/app-config
ENV_NAME=$(kubectl get pod config-pod -n q2-config -o jsonpath='{.spec.containers[0].env[?(@.name=="APP_PORT")].valueFrom.configMapKeyRef.key}')
MOUNT=$(kubectl get pod config-pod -n q2-config -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/etc/app-config")].mountPath}')
[ "$ENV_NAME" = "PORT" ] && [ "$MOUNT" = "/etc/app-config" ] && exit 0 || exit 1
