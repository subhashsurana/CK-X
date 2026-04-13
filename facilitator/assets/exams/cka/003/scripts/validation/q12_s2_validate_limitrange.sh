#!/bin/bash
LR=$(kubectl get limitrange test-limits -n test 2>/dev/null)
if [[ -z "$LR" ]]; then
  echo "❌ LimitRange test-limits not found in namespace test"; exit 1
fi
CPU=$(kubectl get limitrange test-limits -n test \
  -o jsonpath='{.spec.limits[0].defaultRequest.cpu}' 2>/dev/null)
if [[ "$CPU" != "100m" ]]; then
  echo "❌ LimitRange defaultRequest.cpu is '$CPU' (expected 100m)"; exit 1
fi
MEMORY=$(kubectl get limitrange test-limits -n test \
  -o jsonpath='{.spec.limits[0].defaultRequest.memory}' 2>/dev/null)
if [[ "$MEMORY" != "128Mi" ]]; then
  echo "❌ LimitRange defaultRequest.memory is '$MEMORY' (expected 128Mi)"; exit 1
fi
echo "✅ LimitRange test-limits exists with correct default requests"; exit 0
