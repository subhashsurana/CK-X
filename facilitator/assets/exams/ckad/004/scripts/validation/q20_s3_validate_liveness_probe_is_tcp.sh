#!/usr/bin/env bash
set -euo pipefail
# Validates the liveness probe is a tcpSocket probe on port 80.
PROBE_PORT=$(kubectl -n p1-liveness get deploy project-23-api -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.tcpSocket.port}')

if [ -z "$PROBE_PORT" ]; then
    echo "Liveness probe is not a TCP probe"
    exit 1
fi

if [ "$PROBE_PORT" != "80" ]; then
    echo "Liveness probe TCP port is $PROBE_PORT, expected 80"
    exit 1
fi
