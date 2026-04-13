#!/bin/bash
TYPE=$(kubectl get service public-web -n services -o jsonpath='{.spec.type}' 2>/dev/null)
PORT=$(kubectl get service public-web -n services -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
TARGET=$(kubectl get service public-web -n services -o jsonpath='{.spec.ports[0].targetPort}' 2>/dev/null)
SELECTOR=$(kubectl get service public-web -n services -o jsonpath='{.spec.selector.app}' 2>/dev/null)
if [[ "$TYPE" != "NodePort" || "$PORT" != "80" || "$TARGET" != "80" || "$SELECTOR" != "public-web" ]]; then
  echo "public-web service type=$TYPE port=$PORT targetPort=$TARGET selector=$SELECTOR"; exit 1
fi
echo "public-web Service is correct"; exit 0
