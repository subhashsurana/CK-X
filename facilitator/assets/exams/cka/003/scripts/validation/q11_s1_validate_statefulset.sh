#!/bin/bash
REPLICAS=$(kubectl get statefulset database-cluster -n databases \
  -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [[ "$REPLICAS" != "3" ]]; then
  echo "❌ StatefulSet database-cluster not found or wrong replicas: $REPLICAS"; exit 1
fi
IMAGE=$(kubectl get statefulset database-cluster -n databases \
  -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [[ "$IMAGE" != "postgres:15" ]]; then
  echo "❌ StatefulSet image is '$IMAGE' (expected postgres:15)"; exit 1
fi
SERVICE=$(kubectl get statefulset database-cluster -n databases \
  -o jsonpath='{.spec.serviceName}' 2>/dev/null)
if [[ "$SERVICE" != "database-cluster" ]]; then
  echo "❌ StatefulSet serviceName is '$SERVICE' (expected database-cluster)"; exit 1
fi
STORAGE=$(kubectl get statefulset database-cluster -n databases \
  -o jsonpath='{.spec.volumeClaimTemplates[0].spec.resources.requests.storage}' 2>/dev/null)
if [[ "$STORAGE" != "10Gi" ]]; then
  echo "❌ StatefulSet volumeClaimTemplates storage is '$STORAGE' (expected 10Gi)"; exit 1
fi
SC=$(kubectl get statefulset database-cluster -n databases \
  -o jsonpath='{.spec.volumeClaimTemplates[0].spec.storageClassName}' 2>/dev/null)
if [[ "$SC" != "standard" ]]; then
  echo "❌ StatefulSet volumeClaimTemplates storageClassName is '$SC' (expected standard)"; exit 1
fi
echo "✅ StatefulSet database-cluster exists with 3 replicas"; exit 0
