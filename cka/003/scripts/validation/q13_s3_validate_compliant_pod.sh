#!/bin/bash
STATUS=$(kubectl get pod secure-pod -n restricted \
  -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$STATUS" != "Running" ]]; then
  echo "❌ Pod secure-pod not Running in restricted namespace (status: ${STATUS:-not found})"; exit 1
fi
IMAGE=$(kubectl get pod secure-pod -n restricted -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
if [[ "$IMAGE" != "nginx:1.27" ]]; then
  echo "❌ secure-pod image is '$IMAGE' (expected nginx:1.27)"; exit 1
fi
RUN_AS_NON_ROOT=$(kubectl get pod secure-pod -n restricted -o jsonpath='{.spec.securityContext.runAsNonRoot}' 2>/dev/null)
if [[ "$RUN_AS_NON_ROOT" != "true" ]]; then
  RUN_AS_NON_ROOT=$(kubectl get pod secure-pod -n restricted -o jsonpath='{.spec.containers[0].securityContext.runAsNonRoot}' 2>/dev/null)
fi
if [[ "$RUN_AS_NON_ROOT" != "true" ]]; then
  echo "❌ secure-pod is missing runAsNonRoot=true"; exit 1
fi
SECCOMP=$(kubectl get pod secure-pod -n restricted -o jsonpath='{.spec.securityContext.seccompProfile.type}' 2>/dev/null)
if [[ -z "$SECCOMP" ]]; then
  SECCOMP=$(kubectl get pod secure-pod -n restricted -o jsonpath='{.spec.containers[0].securityContext.seccompProfile.type}' 2>/dev/null)
fi
if [[ "$SECCOMP" != "RuntimeDefault" ]]; then
  echo "❌ secure-pod seccompProfile.type is '$SECCOMP' (expected RuntimeDefault)"; exit 1
fi
ALLOW_PRIV=$(kubectl get pod secure-pod -n restricted -o jsonpath='{.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null)
if [[ "$ALLOW_PRIV" != "false" ]]; then
  echo "❌ secure-pod must set allowPrivilegeEscalation=false"; exit 1
fi
CAPS=$(kubectl get pod secure-pod -n restricted -o jsonpath='{.spec.containers[0].securityContext.capabilities.drop[*]}' 2>/dev/null)
if ! echo "$CAPS" | grep -q "ALL"; then
  echo "❌ secure-pod must drop ALL capabilities"; exit 1
fi
echo "✅ Compliant pod secure-pod is Running in restricted namespace"; exit 0
