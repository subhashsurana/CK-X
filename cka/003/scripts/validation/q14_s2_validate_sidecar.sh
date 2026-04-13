#!/bin/bash
# Check for native sidecar (initContainer with restartPolicy: Always)
SIDECAR=$(kubectl get pod app-with-logger -n default \
  -o jsonpath='{.spec.initContainers[*].name}' 2>/dev/null)
if ! echo "$SIDECAR" | grep -q "log-streamer"; then
  echo "❌ Native sidecar initContainer 'log-streamer' not found"; exit 1
fi
RESTART=$(kubectl get pod app-with-logger -n default \
  -o jsonpath='{.spec.initContainers[?(@.name=="log-streamer")].restartPolicy}' 2>/dev/null)
if [[ "$RESTART" != "Always" ]]; then
  echo "❌ Sidecar log-streamer restartPolicy is '$RESTART' (expected Always for native sidecar)"; exit 1
fi
echo "✅ Native sidecar log-streamer present with restartPolicy: Always"; exit 0
