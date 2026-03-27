#!/bin/bash
kubectl get deploy web-app -n q5-kustomize -o jsonpath='{.spec.replicas}' | grep -q '3' && exit 0 || exit 1
