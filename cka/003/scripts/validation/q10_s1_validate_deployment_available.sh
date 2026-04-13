#!/bin/bash
if ! kubectl rollout status deployment/broken-web -n troubleshooting --timeout=10s >/dev/null 2>&1; then
  echo "❌ Deployment broken-web is not successfully rolled out"; exit 1
fi
AVAILABLE=$(kubectl get deployment broken-web -n troubleshooting -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
if [[ "$AVAILABLE" != "2" ]]; then
  echo "❌ Deployment broken-web has $AVAILABLE available replicas (expected 2)"; exit 1
fi
echo "✅ Deployment broken-web has 2 available replicas"; exit 0
