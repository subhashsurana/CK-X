#!/bin/bash
# Q8 Step 2: Verify ALL security context requirements
RUN_AS_NON_ROOT=$(kubectl get pod secure-vault -n q8-security -o jsonpath='{.spec.securityContext.runAsNonRoot}' 2>/dev/null)
RUN_AS_USER=$(kubectl get pod secure-vault -n q8-security -o jsonpath='{.spec.securityContext.runAsUser}' 2>/dev/null)
READ_ONLY=$(kubectl get pod secure-vault -n q8-security -o jsonpath='{.spec.containers[0].securityContext.readOnlyRootFilesystem}' 2>/dev/null)
DROP_CAPS=$(kubectl get pod secure-vault -n q8-security -o jsonpath='{.spec.containers[0].securityContext.capabilities.drop[*]}' 2>/dev/null)

[ "$RUN_AS_NON_ROOT" = "true" ] && \
[ "$RUN_AS_USER" = "2000" ] && \
[ "$READ_ONLY" = "true" ] && \
echo "$DROP_CAPS" | grep -q 'NET_RAW' && exit 0 || exit 1
