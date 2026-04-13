#!/bin/bash
MIN=$(kubectl get hpa web-app-hpa -n production -o jsonpath='{.spec.minReplicas}' 2>/dev/null)
MAX=$(kubectl get hpa web-app-hpa -n production -o jsonpath='{.spec.maxReplicas}' 2>/dev/null)
if [[ "$MIN" != "2" ]]; then
  echo "❌ HPA minReplicas is $MIN (expected 2)"; exit 1
fi
if [[ "$MAX" != "10" ]]; then
  echo "❌ HPA maxReplicas is $MAX (expected 10)"; exit 1
fi
# Check CPU metric (v2 or v1 HPA)
CPU=$(kubectl get hpa web-app-hpa -n production \
  -o jsonpath='{.spec.metrics[*].resource.target.averageUtilization}' 2>/dev/null)
if [[ -z "$CPU" ]]; then
  CPU=$(kubectl get hpa web-app-hpa -n production \
    -o jsonpath='{.spec.targetCPUUtilizationPercentage}' 2>/dev/null)
fi
if [[ "$CPU" != "70" ]]; then
  echo "❌ HPA CPU target is $CPU% (expected 70%)"; exit 1
fi
echo "✅ HPA config correct: min=2 max=10 CPU=70%"; exit 0
