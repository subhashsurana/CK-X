#!/bin/bash
PODS=$(kubectl get resourcequota governance-quota -n governance -o jsonpath='{.spec.hard.pods}' 2>/dev/null)
CPU=$(kubectl get resourcequota governance-quota -n governance -o jsonpath='{.spec.hard.requests\.cpu}' 2>/dev/null)
MEM=$(kubectl get resourcequota governance-quota -n governance -o jsonpath='{.spec.hard.requests\.memory}' 2>/dev/null)
if [[ "$PODS" != "10" || "$CPU" != "2" || "$MEM" != "2Gi" ]]; then
  echo "governance-quota pods=$PODS cpu=$CPU memory=$MEM"; exit 1
fi
echo "governance-quota is correct"; exit 0
