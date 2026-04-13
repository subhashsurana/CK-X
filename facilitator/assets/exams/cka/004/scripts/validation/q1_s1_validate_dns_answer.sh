#!/bin/bash
VALUE=$(kubectl get configmap dns-answer -n backend -o jsonpath='{.data.fqdn}' 2>/dev/null)
if [[ "$VALUE" != "web-ui.frontend.svc.cluster.local" ]]; then
  echo "dns-answer fqdn is '$VALUE'"; exit 1
fi
echo "dns-answer is correct"; exit 0
