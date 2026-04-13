#!/bin/bash
SIGNER=$(kubectl get csr dev-user-csr -o jsonpath='{.spec.signerName}' 2>/dev/null)
USAGES=$(kubectl get csr dev-user-csr -o jsonpath='{.spec.usages[*]}' 2>/dev/null)
REQUEST=$(kubectl get csr dev-user-csr -o jsonpath='{.spec.request}' 2>/dev/null)
if [[ "$SIGNER" != "kubernetes.io/kube-apiserver-client" || -z "$REQUEST" ]]; then
  echo "dev-user-csr signer or request is invalid"; exit 1
fi
if ! echo "$USAGES" | grep -q "client auth"; then
  echo "dev-user-csr usages are '$USAGES'"; exit 1
fi
echo "dev-user-csr spec is correct"; exit 0
