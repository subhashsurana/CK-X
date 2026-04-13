#!/bin/bash
SCHEDULE=$(kubectl get cronjob cleanup-job -n batch -o jsonpath='{.spec.schedule}' 2>/dev/null)
if [[ "$SCHEDULE" != "*/5 * * * *" ]]; then
  echo "cleanup-job schedule is '$SCHEDULE'"; exit 1
fi
echo "cleanup-job schedule is correct"; exit 0
