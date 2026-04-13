#!/bin/bash
if ! kubectl rollout status deployment/config-consumer -n appconfig --timeout=10s >/dev/null 2>&1; then
  echo "config-consumer rollout is not complete"; exit 1
fi
VALUE=$(kubectl get deployment config-consumer -n appconfig -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="LOG_LEVEL")].valueFrom.configMapKeyRef.name}' 2>/dev/null)
if [[ "$VALUE" != "app-config" ]]; then
  echo "config-consumer is not wired to app-config"; exit 1
fi
echo "config-consumer rollout complete"; exit 0
