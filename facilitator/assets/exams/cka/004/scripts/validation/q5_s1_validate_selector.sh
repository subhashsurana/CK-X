#!/bin/bash
SELECTOR=$(kubectl get service api-service -n troubleshooting -o jsonpath='{.spec.selector.app}' 2>/dev/null)
if [[ "$SELECTOR" != "api-server" ]]; then
  echo "api-service selector app is '$SELECTOR'"; exit 1
fi
echo "api-service selector is correct"; exit 0
