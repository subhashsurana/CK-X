#!/bin/bash
HOST=$(kubectl get ingress api-ingress -n default \
  -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
if [[ "$HOST" != "api.example.com" ]]; then
  echo "❌ Ingress api-ingress missing or wrong hostname: $HOST"; exit 1
fi
CLASS=$(kubectl get ingress api-ingress -n default \
  -o jsonpath='{.spec.ingressClassName}' 2>/dev/null)
if [[ "$CLASS" != "nginx" ]]; then
  echo "❌ Ingress ingressClassName is '$CLASS' (expected nginx)"; exit 1
fi
echo "✅ Ingress api-ingress exists with correct hostname and class"; exit 0
