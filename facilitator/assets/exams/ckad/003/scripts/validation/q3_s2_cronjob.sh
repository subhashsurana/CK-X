#!/bin/bash
kubectl get cronjob old-cron -n q3-api >/dev/null 2>&1 && exit 0 || exit 1
