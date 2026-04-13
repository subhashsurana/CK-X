#!/bin/bash
USER=$(kubectl get secret db-credentials -n data -o jsonpath='{.data.username}' 2>/dev/null | base64 -d 2>/dev/null)
PASS=$(kubectl get secret db-credentials -n data -o jsonpath='{.data.password}' 2>/dev/null | base64 -d 2>/dev/null)
if [[ "$USER" != "admin" || "$PASS" != "s3cr3t" ]]; then
  echo "db-credentials has unexpected values"; exit 1
fi
echo "db-credentials is correct"; exit 0
