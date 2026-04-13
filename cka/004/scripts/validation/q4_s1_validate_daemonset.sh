#!/bin/bash
IMAGE=$(kubectl get daemonset node-logger -n logging -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [[ "$IMAGE" != "busybox:1.36" ]]; then
  echo "node-logger image is '$IMAGE'"; exit 1
fi
echo "node-logger DaemonSet exists"; exit 0
