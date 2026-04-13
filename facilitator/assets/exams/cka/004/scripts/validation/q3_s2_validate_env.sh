#!/bin/bash
USER_REF=$(kubectl get deployment db-client -n data -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="DB_USERNAME")].valueFrom.secretKeyRef.name}' 2>/dev/null)
USER_KEY=$(kubectl get deployment db-client -n data -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="DB_USERNAME")].valueFrom.secretKeyRef.key}' 2>/dev/null)
PASS_REF=$(kubectl get deployment db-client -n data -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="DB_PASSWORD")].valueFrom.secretKeyRef.name}' 2>/dev/null)
PASS_KEY=$(kubectl get deployment db-client -n data -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="DB_PASSWORD")].valueFrom.secretKeyRef.key}' 2>/dev/null)
if [[ "$USER_REF" != "db-credentials" || "$USER_KEY" != "username" || "$PASS_REF" != "db-credentials" || "$PASS_KEY" != "password" ]]; then
  echo "db-client env vars do not reference db-credentials correctly"; exit 1
fi
if ! kubectl rollout status deployment/db-client -n data --timeout=10s >/dev/null 2>&1; then
  echo "db-client rollout is not complete"; exit 1
fi
echo "db-client consumes Secret env vars"; exit 0
