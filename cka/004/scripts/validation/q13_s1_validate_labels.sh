#!/bin/bash
ENFORCE=$(kubectl get namespace restricted-ops -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' 2>/dev/null)
WARN=$(kubectl get namespace restricted-ops -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/warn}' 2>/dev/null)
if [[ "$ENFORCE" != "restricted" || "$WARN" != "restricted" ]]; then
  echo "restricted-ops PSS labels are enforce=$ENFORCE warn=$WARN"; exit 1
fi
echo "restricted-ops PSS labels are correct"; exit 0
