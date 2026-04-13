#!/bin/bash
NP=$(kubectl get networkpolicy frontend-policy -n shop 2>/dev/null)
if [[ -z "$NP" ]]; then
  echo "❌ NetworkPolicy frontend-policy not found in shop"; exit 1
fi
PORT=$(kubectl get networkpolicy frontend-policy -n shop \
  -o jsonpath='{.spec.ingress[*].ports[*].port}' 2>/dev/null)
if ! echo "$PORT" | grep -q "80"; then
  echo "❌ frontend-policy does not allow port 80"; exit 1
fi
SELECTOR=$(kubectl get networkpolicy frontend-policy -n shop \
  -o jsonpath='{.spec.podSelector.matchLabels.tier}' 2>/dev/null)
if [[ "$SELECTOR" != "frontend" ]]; then
  echo "❌ frontend-policy selects tier='$SELECTOR' (expected frontend)"; exit 1
fi
echo "✅ NetworkPolicy frontend-policy exists allowing port 80"; exit 0
