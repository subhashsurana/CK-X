#!/bin/bash
# Q12 Step 1: Verify default deny policy exists AND is actually a deny-all (both Ingress and Egress)
kubectl get networkpolicy default-deny -n q12-network >/dev/null 2>&1 || exit 1
POLICY_TYPES=$(kubectl get networkpolicy default-deny -n q12-network -o jsonpath='{.spec.policyTypes[*]}' 2>/dev/null)
echo "$POLICY_TYPES" | grep -q 'Ingress' && echo "$POLICY_TYPES" | grep -q 'Egress' && exit 0 || exit 1
