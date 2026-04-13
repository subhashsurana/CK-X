#!/bin/bash
if ! command -v helm &>/dev/null; then
  echo "❌ helm not installed"; exit 1
fi
RELEASE=$(helm list -n monitoring -q --filter '^monitoring-stack$' 2>/dev/null)
if [[ -z "$RELEASE" ]]; then
  echo "❌ Helm release monitoring-stack not found in namespace monitoring"; exit 1
fi
if ! helm status monitoring-stack -n monitoring 2>/dev/null | grep -q "STATUS: deployed"; then
  echo "❌ Helm release monitoring-stack is not deployed"; exit 1
fi
if ! helm list -n monitoring --filter '^monitoring-stack$' 2>/dev/null | grep -q "kube-prometheus-stack"; then
  echo "❌ monitoring-stack is not a kube-prometheus-stack release"; exit 1
fi
VALUES=$(helm get values monitoring-stack -n monitoring 2>/dev/null)
if ! echo "$VALUES" | grep -q "replicaCount: 1"; then
  echo "❌ monitoring-stack does not have replicaCount: 1 set"; exit 1
fi
if ! echo "$VALUES" | grep -A2 "prometheusOperator:" | grep -q "enabled: false"; then
  echo "❌ monitoring-stack does not have prometheusOperator.enabled=false set"; exit 1
fi
echo "✅ Helm release monitoring-stack is deployed with the expected chart and values"; exit 0
