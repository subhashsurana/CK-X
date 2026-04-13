#!/bin/bash
HPA=$(kubectl get hpa web-app-hpa -n production 2>/dev/null)
if [[ -z "$HPA" ]]; then
  echo "❌ HPA web-app-hpa not found in production"; exit 1
fi
TARGET=$(kubectl get hpa web-app-hpa -n production \
  -o jsonpath='{.spec.scaleTargetRef.name}' 2>/dev/null)
if [[ "$TARGET" != "web-app" ]]; then
  echo "❌ HPA targets wrong deployment: $TARGET"; exit 1
fi
echo "✅ HPA web-app-hpa exists targeting web-app"; exit 0
