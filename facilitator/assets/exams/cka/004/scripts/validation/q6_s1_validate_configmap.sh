#!/bin/bash
VALUE=$(kubectl get configmap app-config -n appconfig -o jsonpath='{.data.LOG_LEVEL}' 2>/dev/null)
if [[ "$VALUE" != "debug" ]]; then
  echo "LOG_LEVEL is '$VALUE'"; exit 1
fi
echo "app-config updated"; exit 0
