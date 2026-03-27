#!/bin/bash
kubectl get svc external-db -n q10-ingress -o jsonpath='{.spec.externalName}' | grep -q 'database.external.com' && exit 0 || exit 1
