#!/bin/bash
LABEL=$(kubectl get namespace restricted \
  -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/audit}' 2>/dev/null)
if [[ "$LABEL" != "baseline" ]]; then
  echo "❌ Namespace restricted audit label is '$LABEL' (expected baseline)"; exit 1
fi
echo "✅ Namespace restricted has audit=baseline label"; exit 0
