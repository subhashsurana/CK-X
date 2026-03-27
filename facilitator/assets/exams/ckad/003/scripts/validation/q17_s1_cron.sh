#!/bin/bash
kubectl get cronjob strict-cron -n q17-cron -o jsonpath='{.spec.schedule}' | grep -q '^30 \* \* \* \*$' && exit 0 || exit 1
