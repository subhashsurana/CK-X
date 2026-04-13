#!/bin/bash
QUOTA=$(kubectl get resourcequota test-quota -n test 2>/dev/null)
if [[ -z "$QUOTA" ]]; then
  echo "❌ ResourceQuota test-quota not found in namespace test"; exit 1
fi
CPU=$(kubectl get resourcequota test-quota -n test \
  -o jsonpath='{.spec.hard.requests\.cpu}' 2>/dev/null)
if [[ "$CPU" != "4" ]]; then
  echo "❌ ResourceQuota requests.cpu is '$CPU' (expected 4)"; exit 1
fi
LIMIT_CPU=$(kubectl get resourcequota test-quota -n test \
  -o jsonpath='{.spec.hard.limits\.cpu}' 2>/dev/null)
if [[ "$LIMIT_CPU" != "8" ]]; then
  echo "❌ ResourceQuota limits.cpu is '$LIMIT_CPU' (expected 8)"; exit 1
fi
REQ_MEM=$(kubectl get resourcequota test-quota -n test \
  -o jsonpath='{.spec.hard.requests\.memory}' 2>/dev/null)
if [[ "$REQ_MEM" != "8Gi" ]]; then
  echo "❌ ResourceQuota requests.memory is '$REQ_MEM' (expected 8Gi)"; exit 1
fi
LIMIT_MEM=$(kubectl get resourcequota test-quota -n test \
  -o jsonpath='{.spec.hard.limits\.memory}' 2>/dev/null)
if [[ "$LIMIT_MEM" != "16Gi" ]]; then
  echo "❌ ResourceQuota limits.memory is '$LIMIT_MEM' (expected 16Gi)"; exit 1
fi
PODS=$(kubectl get resourcequota test-quota -n test \
  -o jsonpath='{.spec.hard.pods}' 2>/dev/null)
if [[ "$PODS" != "20" ]]; then
  echo "❌ ResourceQuota pods is '$PODS' (expected 20)"; exit 1
fi
echo "✅ ResourceQuota test-quota exists with correct limits"; exit 0
