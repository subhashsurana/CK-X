#!/bin/bash
VALUE=$(kubectl get priorityclass high-priority -o jsonpath='{.value}' 2>/dev/null)
if [[ "$VALUE" != "100000" ]]; then
  echo "❌ PriorityClass high-priority value is '$VALUE' (expected 100000)"; exit 1
fi
GLOBAL=$(kubectl get priorityclass high-priority -o jsonpath='{.globalDefault}' 2>/dev/null)
if [[ -n "$GLOBAL" && "$GLOBAL" != "false" ]]; then
  echo "❌ PriorityClass high-priority globalDefault is '$GLOBAL' (expected false)"; exit 1
fi
PREEMPT=$(kubectl get priorityclass high-priority -o jsonpath='{.preemptionPolicy}' 2>/dev/null)
if [[ "$PREEMPT" != "PreemptLowerPriority" ]]; then
  echo "❌ PriorityClass high-priority preemptionPolicy is '$PREEMPT'"; exit 1
fi
echo "✅ PriorityClass high-priority exists with correct settings"; exit 0
