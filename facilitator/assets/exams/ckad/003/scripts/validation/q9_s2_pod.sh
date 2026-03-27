#!/bin/bash
kubectl get pod api-consumer -n q9-identity -o jsonpath='{.spec.serviceAccountName}' | grep -q 'api-reader' && exit 0 || exit 1
