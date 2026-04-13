#!/bin/bash
NS=$(kubectl get namespace monitoring 2>/dev/null)
if [[ -z "$NS" ]]; then
  echo "❌ Namespace monitoring does not exist"; exit 1
fi
echo "✅ Namespace monitoring exists"; exit 0
