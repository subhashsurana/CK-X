#!/bin/bash
PHASE=$(kubectl get pvc db-pvc -n databases -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$PHASE" != "Bound" ]]; then
  echo "❌ PVC db-pvc not Bound (current: ${PHASE:-not found})"; exit 1
fi
echo "✅ PVC db-pvc is Bound"; exit 0
