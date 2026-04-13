#!/bin/bash
BACKEND=$(kubectl get ingress api-ingress -n default \
  -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
if [[ "$BACKEND" != "api" ]]; then
  echo "❌ Ingress backend service is '$BACKEND' (expected api)"; exit 1
fi
PATH_VAL=$(kubectl get ingress api-ingress -n default \
  -o jsonpath='{.spec.rules[0].http.paths[0].path}' 2>/dev/null)
if ! echo "$PATH_VAL" | grep -q "/api"; then
  echo "❌ Ingress path is '$PATH_VAL' (expected /api)"; exit 1
fi
echo "✅ Ingress routes /api to service api"; exit 0
