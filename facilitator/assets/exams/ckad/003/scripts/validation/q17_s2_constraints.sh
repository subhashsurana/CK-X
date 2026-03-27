#!/bin/bash
# Q17 Step 2: Verify BOTH concurrencyPolicy AND startingDeadlineSeconds
CONCURRENCY=$(kubectl get cronjob strict-cron -n q17-cron -o jsonpath='{.spec.concurrencyPolicy}' 2>/dev/null)
DEADLINE=$(kubectl get cronjob strict-cron -n q17-cron -o jsonpath='{.spec.startingDeadlineSeconds}' 2>/dev/null)
[ "$CONCURRENCY" = "Forbid" ] && [ "$DEADLINE" = "20" ] && exit 0 || exit 1
