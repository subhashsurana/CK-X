#!/bin/bash
STATUS=$(kubectl get csr dev-user-csr -o jsonpath='{.status.conditions[?(@.type=="Approved")].type}' 2>/dev/null)
if [[ "$STATUS" != "Approved" ]]; then
  echo "dev-user-csr is not Approved"; exit 1
fi
echo "dev-user-csr is approved"; exit 0
