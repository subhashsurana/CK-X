#!/bin/bash
# Q13 Step 1: Verify PVC exists with correct spec (check spec, not status which may not be bound yet)
kubectl get pvc library-pvc -n q13-storage >/dev/null 2>&1 || exit 1
STORAGE=$(kubectl get pvc library-pvc -n q13-storage -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null)
ACCESS=$(kubectl get pvc library-pvc -n q13-storage -o jsonpath='{.spec.accessModes[0]}' 2>/dev/null)
[ "$STORAGE" = "2Gi" ] && [ "$ACCESS" = "ReadWriteOnce" ] && exit 0 || exit 1
