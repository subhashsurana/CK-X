#!/bin/bash
NP=$(kubectl get networkpolicy database-policy -n shop 2>/dev/null)
if [[ -z "$NP" ]]; then
  echo "❌ NetworkPolicy database-policy not found in shop"; exit 1
fi
PORT=$(kubectl get networkpolicy database-policy -n shop \
  -o jsonpath='{.spec.ingress[*].ports[*].port}' 2>/dev/null)
if ! echo "$PORT" | grep -q "5432"; then
  echo "❌ database-policy does not allow port 5432"; exit 1
fi
SELECTOR=$(kubectl get networkpolicy database-policy -n shop \
  -o jsonpath='{.spec.podSelector.matchLabels.tier}' 2>/dev/null)
if [[ "$SELECTOR" != "database" ]]; then
  echo "❌ database-policy selects tier='$SELECTOR' (expected database)"; exit 1
fi
SOURCE=$(kubectl get networkpolicy database-policy -n shop \
  -o jsonpath='{.spec.ingress[*].from[*].podSelector.matchLabels.tier}' 2>/dev/null)
if ! echo "$SOURCE" | grep -q "backend"; then
  echo "❌ database-policy does not restrict ingress source to tier=backend"; exit 1
fi
echo "✅ NetworkPolicy database-policy exists allowing port 5432 from backend"; exit 0
