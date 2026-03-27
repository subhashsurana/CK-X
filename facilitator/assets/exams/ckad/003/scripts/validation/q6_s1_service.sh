#!/bin/bash
kubectl get svc app-service -n q6-blue-green -o jsonpath='{.spec.selector.version}' | grep -q 'v2' && exit 0 || exit 1
