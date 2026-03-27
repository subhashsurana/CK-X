#!/bin/bash
USER_SECRET=$(kubectl get pod secret-reader -n q19-secrets -o jsonpath='{.spec.containers[0].env[?(@.name=="DB_USER")].valueFrom.secretKeyRef.name}' 2>/dev/null)
USER_KEY=$(kubectl get pod secret-reader -n q19-secrets -o jsonpath='{.spec.containers[0].env[?(@.name=="DB_USER")].valueFrom.secretKeyRef.key}' 2>/dev/null)
PASS_SECRET=$(kubectl get pod secret-reader -n q19-secrets -o jsonpath='{.spec.containers[0].env[?(@.name=="DB_PASSWORD")].valueFrom.secretKeyRef.name}' 2>/dev/null)
PASS_KEY=$(kubectl get pod secret-reader -n q19-secrets -o jsonpath='{.spec.containers[0].env[?(@.name=="DB_PASSWORD")].valueFrom.secretKeyRef.key}' 2>/dev/null)

[ "$USER_SECRET" = "db-secret" ] && \
[ "$USER_KEY" = "username" ] && \
[ "$PASS_SECRET" = "db-secret" ] && \
[ "$PASS_KEY" = "password" ] && exit 0 || exit 1
