#!/bin/bash
VALUE=$(kubectl get priorityclass batch-priority -o jsonpath='{.value}' 2>/dev/null)
if [[ "$VALUE" != "5000" ]]; then
  echo "batch-priority value is '$VALUE'"; exit 1
fi
GLOBAL=$(kubectl get priorityclass batch-priority -o jsonpath='{.globalDefault}' 2>/dev/null)
if [[ -n "$GLOBAL" && "$GLOBAL" != "false" ]]; then
  echo "batch-priority globalDefault is '$GLOBAL'"; exit 1
fi
echo "batch-priority is correct"; exit 0
