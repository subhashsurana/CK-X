#!/bin/bash
PHASE=$(kubectl get pod app-frontend -n production -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$PHASE" != "Running" ]]; then
  echo "❌ Pod app-frontend is not Running (current: ${PHASE:-not found})"; exit 1
fi
echo "✅ Pod app-frontend is Running"; exit 0
