#!/bin/bash
SUBJECT=$(kubectl get rolebinding dev-binding -n staging -o jsonpath='{.subjects[*].name}' 2>/dev/null)
if ! echo "$SUBJECT" | grep -q "dev-user"; then
  echo "❌ RoleBinding dev-binding not found or doesn't bind dev-user"; exit 1
fi
ROLEREF=$(kubectl get rolebinding dev-binding -n staging -o jsonpath='{.roleRef.name}' 2>/dev/null)
if [[ "$ROLEREF" != "dev-role" ]]; then
  echo "❌ RoleBinding dev-binding references wrong role: $ROLEREF"; exit 1
fi
echo "✅ RoleBinding dev-binding correctly binds dev-user to dev-role"; exit 0
