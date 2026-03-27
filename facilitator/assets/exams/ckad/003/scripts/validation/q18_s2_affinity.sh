#!/bin/bash
# Q18 Step 2: Verify nodeAffinity requires disktype=ssd
AFFINITY_KEY=$(kubectl get pod batch-processor -n q18-affinity -o jsonpath='{.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key}' 2>/dev/null)
AFFINITY_VALUES=$(kubectl get pod batch-processor -n q18-affinity -o jsonpath='{.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]}' 2>/dev/null)
[ "$AFFINITY_KEY" = "disktype" ] && [ "$AFFINITY_VALUES" = "ssd" ] && exit 0 || exit 1
