#!/bin/bash
IMAGE=$(kubectl get cronjob cleanup-job -n batch -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].image}' 2>/dev/null)
COMMAND=$(kubectl get cronjob cleanup-job -n batch -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].command[*]} {.spec.jobTemplate.spec.template.spec.containers[0].args[*]}' 2>/dev/null)
if [[ "$IMAGE" != "busybox:1.36" ]]; then
  echo "cleanup-job image is '$IMAGE'"; exit 1
fi
if ! echo "$COMMAND" | grep -q "/tmp/cache"; then
  echo "cleanup-job command does not reference /tmp/cache"; exit 1
fi
echo "cleanup-job command is correct"; exit 0
