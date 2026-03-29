#!/usr/bin/env bash
set -euo pipefail

ENDPOINTS=$(kubectl -n p3-readiness get endpoints earth-3cc-web-svc -o jsonpath='{range .subsets[*].addresses[*]}{.ip}{"\n"}{end}' 2>/dev/null || true)

if [[ -z "${ENDPOINTS}" ]]; then
  echo "Service has no endpoints" >&2
  exit 1
fi
