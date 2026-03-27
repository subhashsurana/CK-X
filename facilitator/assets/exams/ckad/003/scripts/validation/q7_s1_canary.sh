#!/bin/bash
# Q7 Step 1: Verify canary deployment has 1 replica, correct image, AND the critical app=frontend label
REPLICAS=$(kubectl get deploy app-canary -n q7-canary -o jsonpath='{.spec.replicas}' 2>/dev/null)
APP_LABEL=$(kubectl get deploy app-canary -n q7-canary -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null)
IMAGE=$(kubectl get deploy app-canary -n q7-canary -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
[ "$REPLICAS" = "1" ] && [ "$APP_LABEL" = "frontend" ] && echo "$IMAGE" | grep -q 'nginx:1.25' && exit 0 || exit 1
