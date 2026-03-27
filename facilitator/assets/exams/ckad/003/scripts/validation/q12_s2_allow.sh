#!/bin/bash
kubectl get networkpolicy allow-web -n q12-network -o jsonpath='{.spec.ingress[0].from[0].podSelector.matchLabels.role}' | grep -q 'gateway' && exit 0 || exit 1
