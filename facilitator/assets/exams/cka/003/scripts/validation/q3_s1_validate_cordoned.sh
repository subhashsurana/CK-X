#!/bin/bash
TARGET_NODE="k3d-cluster-agent-1"
UNSCHEDULABLE=$(kubectl get node "$TARGET_NODE" -o jsonpath='{.spec.unschedulable}' 2>/dev/null)
if [[ "$UNSCHEDULABLE" != "true" ]]; then
  echo "❌ $TARGET_NODE is not cordoned (unschedulable is not true)"; exit 1
fi
echo "✅ $TARGET_NODE is cordoned"; exit 0
