#!/bin/bash
PC=$(kubectl get pod important-nginx -n default -o jsonpath='{.spec.priorityClassName}' 2>/dev/null)
if [[ "$PC" != "high-priority" ]]; then
  echo "❌ Pod important-nginx priorityClassName is '$PC' (expected high-priority)"; exit 1
fi
STATUS=$(kubectl get pod important-nginx -n default -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$STATUS" != "Running" ]]; then
  echo "❌ Pod important-nginx is not Running (current: ${STATUS:-not found})"; exit 1
fi
echo "✅ Pod important-nginx uses high-priority and is Running"; exit 0
