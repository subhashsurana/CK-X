#!/bin/bash
LABEL=$(kubectl get namespace restricted \
  -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' 2>/dev/null)
if [[ "$LABEL" != "restricted" ]]; then
  echo "❌ Namespace restricted enforce label is '$LABEL' (expected restricted)"; exit 1
fi
echo "✅ Namespace restricted has enforce=restricted label"; exit 0
