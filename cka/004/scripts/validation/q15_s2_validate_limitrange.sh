#!/bin/bash
CPU=$(kubectl get limitrange governance-limits -n governance -o jsonpath='{.spec.limits[0].defaultRequest.cpu}' 2>/dev/null)
MEM=$(kubectl get limitrange governance-limits -n governance -o jsonpath='{.spec.limits[0].defaultRequest.memory}' 2>/dev/null)
if [[ "$CPU" != "100m" || "$MEM" != "128Mi" ]]; then
  echo "governance-limits cpu=$CPU memory=$MEM"; exit 1
fi
echo "governance-limits is correct"; exit 0
