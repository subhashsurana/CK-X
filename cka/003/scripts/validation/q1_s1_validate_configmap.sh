#!/bin/bash
CM=$(kubectl get configmap app-config -n production -o jsonpath='{.data.config\.yaml}' 2>/dev/null)
if [[ -z "$CM" ]]; then
  echo "❌ ConfigMap app-config not found in namespace production or missing key config.yaml"; exit 1
fi
if ! echo "$CM" | grep -q "database_host"; then
  echo "❌ ConfigMap data missing 'database_host' key"; exit 1
fi
echo "✅ ConfigMap app-config exists with correct data"; exit 0
