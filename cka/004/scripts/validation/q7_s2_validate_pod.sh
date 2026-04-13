#!/bin/bash
PC=$(kubectl get pod batch-worker -n default -o jsonpath='{.spec.priorityClassName}' 2>/dev/null)
PHASE=$(kubectl get pod batch-worker -n default -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$PC" != "batch-priority" || "$PHASE" != "Running" ]]; then
  echo "batch-worker priorityClassName=$PC phase=${PHASE:-not found}"; exit 1
fi
echo "batch-worker is running with batch-priority"; exit 0
