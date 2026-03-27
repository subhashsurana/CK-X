#!/bin/bash
INGRESS_EXISTS=$(kubectl get ingress main-ingress -n q10-ingress >/dev/null 2>&1; echo $?)
[ "$INGRESS_EXISTS" = "0" ] || exit 1
INGRESS_JSON=$(kubectl get ingress main-ingress -n q10-ingress -o json 2>/dev/null)
USE_REGEX=$(echo "$INGRESS_JSON" | jq -r '.metadata.annotations["nginx.ingress.kubernetes.io/use-regex"] // empty')
REWRITE=$(echo "$INGRESS_JSON" | jq -r '.metadata.annotations["nginx.ingress.kubernetes.io/rewrite-target"] // empty')
PATH_VALUE=$(echo "$INGRESS_JSON" | jq -r '.spec.rules[0].http.paths[0].path // empty')
PATH_TYPE=$(echo "$INGRESS_JSON" | jq -r '.spec.rules[0].http.paths[0].pathType // empty')
SERVICE_NAME=$(echo "$INGRESS_JSON" | jq -r '.spec.rules[0].http.paths[0].backend.service.name // empty')
SERVICE_PORT=$(echo "$INGRESS_JSON" | jq -r '.spec.rules[0].http.paths[0].backend.service.port.number // empty')

[ "$USE_REGEX" = "true" ] && \
[ "$REWRITE" = "/\\$2" ] && \
[ "$PATH_VALUE" = "/api(/|$)(.*)" ] && \
[ "$PATH_TYPE" = "ImplementationSpecific" ] && \
[ "$SERVICE_NAME" = "api-svc" ] && \
[ "$SERVICE_PORT" = "8080" ] && exit 0 || exit 1
