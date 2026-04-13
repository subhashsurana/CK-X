#!/bin/bash
CLUSTER_IP=$(kubectl get service database-cluster -n databases \
  -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
if [[ "$CLUSTER_IP" != "None" ]]; then
  echo "❌ Service database-cluster is not headless (clusterIP: $CLUSTER_IP)"; exit 1
fi
PORT=$(kubectl get service database-cluster -n databases \
  -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
if [[ "$PORT" != "5432" ]]; then
  echo "❌ Headless service port is $PORT (expected 5432)"; exit 1
fi
SELECTOR=$(kubectl get service database-cluster -n databases \
  -o jsonpath='{.spec.selector.app}' 2>/dev/null)
if [[ "$SELECTOR" != "database-cluster" ]]; then
  echo "❌ Headless service selector app='$SELECTOR' (expected database-cluster)"; exit 1
fi
echo "✅ Headless service database-cluster exists on port 5432"; exit 0
