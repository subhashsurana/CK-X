#!/bin/bash
kubectl get pod limited-pod -n q16-quota -o jsonpath='{.status.phase}' | grep -q 'Running' && exit 0 || exit 1
