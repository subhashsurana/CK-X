#!/bin/bash
ROLE=$(kubectl get role dev-role -n staging -o jsonpath='{.rules}' 2>/dev/null)
if [[ -z "$ROLE" ]]; then
  echo "❌ Role dev-role not found in namespace staging"; exit 1
fi
if ! kubectl get role dev-role -n staging -o jsonpath='{.rules[*].resources}' | grep -q "pods"; then
  echo "❌ Role dev-role missing pods resource"; exit 1
fi
echo "✅ Role dev-role exists with correct permissions"; exit 0
