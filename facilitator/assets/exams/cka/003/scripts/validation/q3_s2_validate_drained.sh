#!/bin/bash
TARGET_NODE="k3d-cluster-agent-1"
# Allow DaemonSet pods, check for others
NON_DS=$(kubectl get pods -A -o wide --field-selector="spec.nodeName=$TARGET_NODE" --no-headers 2>/dev/null | \
  awk '{print $1" "$2}' | while read -r ns pod; do
    [[ -z "$ns" || -z "$pod" ]] && continue
    OWNER=$(kubectl get pod "$pod" -n "$ns" -o jsonpath='{.metadata.ownerReferences[0].kind}' 2>/dev/null)
    [[ "$OWNER" != "DaemonSet" ]] && echo "$ns/$pod"
  done)
if [[ -n "$NON_DS" ]]; then
  echo "❌ Non-DaemonSet pods still on $TARGET_NODE: $NON_DS"; exit 1
fi
echo "✅ $TARGET_NODE drained — no non-DaemonSet pods remaining"; exit 0
