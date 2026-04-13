#!/bin/bash
TLS=$(kubectl get ingress api-ingress -n default \
  -o jsonpath='{.spec.tls[0].secretName}' 2>/dev/null)
if [[ "$TLS" != "api-tls-cert" ]]; then
  echo "❌ Ingress TLS secret is '$TLS' (expected api-tls-cert)"; exit 1
fi
echo "✅ Ingress has TLS configured with secret api-tls-cert"; exit 0
