#!/bin/bash
PHASE=$(kubectl get pod dns-check -n backend -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$PHASE" != "Succeeded" ]]; then
  echo "dns-check phase is '${PHASE:-not found}'"; exit 1
fi
LOGS=$(kubectl logs dns-check -n backend 2>/dev/null)
if ! echo "$LOGS" | grep -q "web-ui.frontend.svc.cluster.local"; then
  echo "dns-check logs do not include expected FQDN"; exit 1
fi
echo "dns-check completed successfully"; exit 0
