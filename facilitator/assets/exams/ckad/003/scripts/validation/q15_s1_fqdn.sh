#!/bin/bash
kubectl get pod frontend-fixed -n q15-cross-ns -o jsonpath='{.spec.containers[0].env[?(@.name=="BACKEND_URL")].value}' | grep -q '^backend-svc.q15-backend.svc.cluster.local:8080$' && exit 0 || exit 1
