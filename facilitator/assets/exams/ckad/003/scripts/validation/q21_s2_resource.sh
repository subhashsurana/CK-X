#!/bin/bash
kubectl get widget blue-widget -n q21-crd >/dev/null 2>&1 || exit 1
IMAGE=$(kubectl get widget blue-widget -n q21-crd -o jsonpath='{.spec.image}' 2>/dev/null)
REPLICAS=$(kubectl get widget blue-widget -n q21-crd -o jsonpath='{.spec.replicas}' 2>/dev/null)
[ "$IMAGE" = "nginx:1.25" ] && [ "$REPLICAS" = "2" ] && exit 0 || exit 1
