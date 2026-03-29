#!/usr/bin/env bash
set -euo pipefail
# Validate that the moved pod still uses the seeded source image.
kubectl -n pod-move-target get pod webserver-sat-003 -o jsonpath='{.spec.containers[0].image}' | grep -qx 'nginx:1.16.1-alpine'
