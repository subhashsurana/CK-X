#!/bin/bash
RESULT=$(kubectl auth can-i list pods -n staging --as=dev-user 2>/dev/null)
if [[ "$RESULT" != "yes" ]]; then
  echo "❌ dev-user cannot list pods in staging"; exit 1
fi
echo "✅ dev-user can list pods in staging"; exit 0
