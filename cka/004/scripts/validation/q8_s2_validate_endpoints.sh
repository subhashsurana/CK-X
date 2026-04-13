#!/bin/bash
ENDPOINTS=$(kubectl get endpoints public-web -n services -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null)
if [[ -z "$ENDPOINTS" ]]; then
  echo "public-web has no endpoints"; exit 1
fi
echo "public-web has endpoints"; exit 0
