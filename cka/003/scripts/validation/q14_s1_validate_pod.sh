#!/bin/bash
STATUS=$(kubectl get pod app-with-logger -n default \
  -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$STATUS" != "Running" ]]; then
  echo "❌ Pod app-with-logger not Running (status: ${STATUS:-not found})"; exit 1
fi
echo "✅ Pod app-with-logger is Running"; exit 0
