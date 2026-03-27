#!/bin/bash
kubectl get secret db-secret -n q19-secrets >/dev/null 2>&1 || exit 1
USERNAME=$(kubectl get secret db-secret -n q19-secrets -o jsonpath='{.data.username}' 2>/dev/null | base64 -d 2>/dev/null)
PASSWORD=$(kubectl get secret db-secret -n q19-secrets -o jsonpath='{.data.password}' 2>/dev/null | base64 -d 2>/dev/null)
[ "$USERNAME" = "appuser" ] && [ "$PASSWORD" = "s3cur3" ] && exit 0 || exit 1
