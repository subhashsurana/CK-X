#!/bin/bash
ENDPOINTS=$(kubectl get endpoints api-service -n troubleshooting -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null)
if [[ -z "$ENDPOINTS" ]]; then
  echo "api-service has no endpoints"; exit 1
fi
echo "api-service has endpoints"; exit 0
