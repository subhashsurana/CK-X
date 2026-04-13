#!/bin/bash
NP=$(kubectl get networkpolicy backend-policy -n shop 2>/dev/null)
if [[ -z "$NP" ]]; then
  echo "❌ NetworkPolicy backend-policy not found in shop"; exit 1
fi
PORT=$(kubectl get networkpolicy backend-policy -n shop \
  -o jsonpath='{.spec.ingress[*].ports[*].port}' 2>/dev/null)
if ! echo "$PORT" | grep -q "3000"; then
  echo "❌ backend-policy does not allow port 3000"; exit 1
fi
SELECTOR=$(kubectl get networkpolicy backend-policy -n shop \
  -o jsonpath='{.spec.podSelector.matchLabels.tier}' 2>/dev/null)
if [[ "$SELECTOR" != "backend" ]]; then
  echo "❌ backend-policy selects tier='$SELECTOR' (expected backend)"; exit 1
fi
SOURCE=$(kubectl get networkpolicy backend-policy -n shop \
  -o jsonpath='{.spec.ingress[*].from[*].podSelector.matchLabels.tier}' 2>/dev/null)
if ! echo "$SOURCE" | grep -q "frontend"; then
  echo "❌ backend-policy does not restrict ingress source to tier=frontend"; exit 1
fi
echo "✅ NetworkPolicy backend-policy exists allowing port 3000 from frontend"; exit 0
