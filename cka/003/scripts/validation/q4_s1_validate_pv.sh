#!/bin/bash
PV=$(kubectl get pv db-pv -o jsonpath='{.spec.capacity.storage}' 2>/dev/null)
if [[ "$PV" != "5Gi" ]]; then
  echo "❌ PV db-pv not found or wrong capacity (got: $PV)"; exit 1
fi
SC=$(kubectl get pv db-pv -o jsonpath='{.spec.storageClassName}' 2>/dev/null)
if [[ "$SC" != "fast-ssd" ]]; then
  echo "❌ PV db-pv wrong storageClassName: $SC"; exit 1
fi
echo "✅ PV db-pv exists with 5Gi capacity and fast-ssd storageClass"; exit 0
