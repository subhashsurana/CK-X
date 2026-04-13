#!/bin/bash
PHASE=$(kubectl get pod restricted-nginx -n restricted-ops -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$PHASE" != "Running" ]]; then
  echo "restricted-nginx phase is '${PHASE:-not found}'"; exit 1
fi
ALLOW=$(kubectl get pod restricted-nginx -n restricted-ops -o jsonpath='{.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null)
CAPS=$(kubectl get pod restricted-nginx -n restricted-ops -o jsonpath='{.spec.containers[0].securityContext.capabilities.drop[*]}' 2>/dev/null)
RUN_AS=$(kubectl get pod restricted-nginx -n restricted-ops -o jsonpath='{.spec.securityContext.runAsNonRoot}' 2>/dev/null)
if [[ "$RUN_AS" != "true" ]]; then
  RUN_AS=$(kubectl get pod restricted-nginx -n restricted-ops -o jsonpath='{.spec.containers[0].securityContext.runAsNonRoot}' 2>/dev/null)
fi
SECCOMP=$(kubectl get pod restricted-nginx -n restricted-ops -o jsonpath='{.spec.securityContext.seccompProfile.type}' 2>/dev/null)
if [[ -z "$SECCOMP" ]]; then
  SECCOMP=$(kubectl get pod restricted-nginx -n restricted-ops -o jsonpath='{.spec.containers[0].securityContext.seccompProfile.type}' 2>/dev/null)
fi
if [[ "$ALLOW" != "false" || "$RUN_AS" != "true" || "$SECCOMP" != "RuntimeDefault" ]] || ! echo "$CAPS" | grep -q "ALL"; then
  echo "restricted-nginx securityContext is not restricted-compliant"; exit 1
fi
echo "restricted-nginx is compliant and Running"; exit 0
