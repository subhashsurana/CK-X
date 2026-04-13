#!/bin/bash
VOLS=$(kubectl get pod app-frontend -n production -o jsonpath='{.spec.volumes[*].configMap.name}' 2>/dev/null)
if ! echo "$VOLS" | grep -q "app-config"; then
  echo "❌ Pod app-frontend does not mount ConfigMap app-config"; exit 1
fi
if ! kubectl exec app-frontend -n production -- test -f /etc/app/config.yaml 2>/dev/null; then
  echo "❌ /etc/app/config.yaml is not present inside app-frontend"; exit 1
fi
CONTENT=$(kubectl exec app-frontend -n production -- cat /etc/app/config.yaml 2>/dev/null)
if ! echo "$CONTENT" | grep -q "database_host: postgres.production.svc.cluster.local"; then
  echo "❌ /etc/app/config.yaml does not contain the expected database_host value"; exit 1
fi
echo "✅ Pod app-frontend mounts app-config at /etc/app/config.yaml"; exit 0
