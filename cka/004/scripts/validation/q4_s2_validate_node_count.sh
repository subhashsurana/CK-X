#!/bin/bash
DESIRED=$(kubectl get daemonset node-logger -n logging -o jsonpath='{.status.desiredNumberScheduled}' 2>/dev/null)
READY=$(kubectl get daemonset node-logger -n logging -o jsonpath='{.status.numberReady}' 2>/dev/null)
if [[ "$DESIRED" -lt 2 || "$READY" -lt 2 ]]; then
  echo "node-logger desired=$DESIRED ready=$READY"; exit 1
fi
echo "node-logger is ready on worker nodes"; exit 0
