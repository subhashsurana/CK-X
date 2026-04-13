#!/bin/bash
PROVISIONER=$(kubectl get storageclass fast-local -o jsonpath='{.provisioner}' 2>/dev/null)
BINDING=$(kubectl get storageclass fast-local -o jsonpath='{.volumeBindingMode}' 2>/dev/null)
if [[ "$PROVISIONER" != "rancher.io/local-path" || "$BINDING" != "WaitForFirstConsumer" ]]; then
  echo "fast-local provisioner=$PROVISIONER binding=$BINDING"; exit 1
fi
echo "fast-local StorageClass is correct"; exit 0
