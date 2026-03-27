#!/bin/bash
# Q11 Step 2: Verify liveness and readiness probes are configured with correct details
LIVENESS_PATH=$(kubectl get pod slow-app -n q11-probes -o jsonpath='{.spec.containers[0].livenessProbe.httpGet.path}' 2>/dev/null)
LIVENESS_PERIOD=$(kubectl get pod slow-app -n q11-probes -o jsonpath='{.spec.containers[0].livenessProbe.periodSeconds}' 2>/dev/null)
READINESS_PORT=$(kubectl get pod slow-app -n q11-probes -o jsonpath='{.spec.containers[0].readinessProbe.tcpSocket.port}' 2>/dev/null)
READINESS_PERIOD=$(kubectl get pod slow-app -n q11-probes -o jsonpath='{.spec.containers[0].readinessProbe.periodSeconds}' 2>/dev/null)

[ "$LIVENESS_PATH" = "/health" ] && \
[ "$LIVENESS_PERIOD" = "10" ] && \
[ "$READINESS_PORT" = "80" ] && \
[ "$READINESS_PERIOD" = "5" ] && exit 0 || exit 1
