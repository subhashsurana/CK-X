#!/bin/bash
IMAGE=$(kubectl get deployment payment-api -n payments -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [[ "$IMAGE" != "nginx:1.26" ]]; then
  echo "payment-api image is '$IMAGE'"; exit 1
fi
echo "payment-api image restored"; exit 0
