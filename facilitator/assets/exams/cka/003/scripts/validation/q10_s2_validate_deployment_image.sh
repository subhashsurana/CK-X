#!/bin/bash
IMAGE=$(kubectl get deployment broken-web -n troubleshooting \
  -o jsonpath='{.spec.template.spec.containers[?(@.name=="web")].image}' 2>/dev/null)
if [[ "$IMAGE" != "nginx:1.27" ]]; then
  echo "❌ Deployment broken-web image is '$IMAGE' (expected nginx:1.27)"; exit 1
fi
echo "✅ Deployment broken-web uses image nginx:1.27"; exit 0
