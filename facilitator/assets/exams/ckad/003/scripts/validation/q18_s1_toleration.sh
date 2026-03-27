#!/bin/bash
# Q18 Step 1: Verify toleration with correct key=type, value=batch, effect=NoSchedule
TOLERATION_KEY=$(kubectl get pod batch-processor -n q18-affinity -o jsonpath='{.spec.tolerations[?(@.key=="type")].key}' 2>/dev/null)
TOLERATION_VALUE=$(kubectl get pod batch-processor -n q18-affinity -o jsonpath='{.spec.tolerations[?(@.key=="type")].value}' 2>/dev/null)
TOLERATION_EFFECT=$(kubectl get pod batch-processor -n q18-affinity -o jsonpath='{.spec.tolerations[?(@.key=="type")].effect}' 2>/dev/null)
[ "$TOLERATION_KEY" = "type" ] && [ "$TOLERATION_VALUE" = "batch" ] && [ "$TOLERATION_EFFECT" = "NoSchedule" ] && exit 0 || exit 1
