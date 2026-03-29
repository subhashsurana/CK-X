#!/usr/bin/env bash
set -euo pipefail

# Require helm
if ! command -v helm >/dev/null 2>&1; then
  echo "helm not found" >&2
  exit 1
fi

ns=helm
rel=internal-issue-report-apiv2

# Must exist first
if ! helm -n "$ns" list 2>/dev/null | awk 'NR>1 {print $1}' | grep -qx "$rel"; then
  exit 1
fi

# Consider it upgraded if release revision >= 2
rev=$(helm -n "$ns" history "$rel" 2>/dev/null | awk 'NR>1 {last=$1} END {print last+0}')
test "$rev" -ge 2 || exit 1

# Verify it was actually upgraded to a newer image (not just a no-op redeploy of 1.21.6)
IMAGE=$(kubectl -n "$ns" get deploy "$rel" -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)
if [[ "$IMAGE" == *":1.21.6"* ]]; then
  echo "Image tag is still 1.21.6, upgrade required" >&2
  exit 1
fi

exit 0
