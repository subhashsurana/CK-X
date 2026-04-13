#!/bin/bash
SC=$(kubectl get pvc fast-data -n storage -o jsonpath='{.spec.storageClassName}' 2>/dev/null)
SIZE=$(kubectl get pvc fast-data -n storage -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null)
if [[ "$SC" != "fast-local" || "$SIZE" != "1Gi" ]]; then
  echo "fast-data storageClass=$SC size=$SIZE"; exit 1
fi
echo "fast-data PVC is correct"; exit 0
