#!/bin/bash
kubectl get sa api-reader -n q9-identity -o jsonpath='{.automountServiceAccountToken}' | grep -q 'false' && exit 0 || exit 1
