#!/bin/bash
kubectl get pod slow-app -n q11-probes -o jsonpath='{.spec.containers[0].startupProbe.failureThreshold}' | grep -q '20' && exit 0 || exit 1
