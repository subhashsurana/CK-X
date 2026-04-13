#!/bin/bash
CLAIM=$(kubectl get deployment db-app -n databases \
  -o jsonpath='{.spec.template.spec.volumes[*].persistentVolumeClaim.claimName}' 2>/dev/null)
if ! echo "$CLAIM" | grep -q "db-pvc"; then
  echo "❌ Deployment db-app does not reference db-pvc"; exit 1
fi
MOUNT=$(kubectl get deployment db-app -n databases \
  -o jsonpath='{.spec.template.spec.containers[*].volumeMounts[*].mountPath}' 2>/dev/null)
if ! echo "$MOUNT" | grep -q "/data"; then
  echo "❌ db-app does not mount PVC at /data"; exit 1
fi
echo "✅ Deployment db-app mounts db-pvc at /data"; exit 0
