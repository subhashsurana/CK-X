#!/bin/bash
if ! kubectl rollout status deployment/payment-api -n payments --timeout=10s >/dev/null 2>&1; then
  echo "payment-api rollout is not complete"; exit 1
fi
AVAILABLE=$(kubectl get deployment payment-api -n payments -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
if [[ "$AVAILABLE" != "2" ]]; then
  echo "payment-api available replicas is '${AVAILABLE:-0}'"; exit 1
fi
echo "payment-api is available"; exit 0
