#!/usr/bin/env bash
set -euo pipefail
# First, get the pod name
POD_NAME=$(kubectl -n init-container get pod -l app=init-web -o jsonpath='{.items[0].metadata.name}')

# Check if pod is ready
POD_STATUS=$(kubectl -n init-container get pod $POD_NAME -o jsonpath='{.status.phase}')
if [ "$POD_STATUS" != "Running" ]; then
    echo "Pod is not running, status: $POD_STATUS"
    exit 1
fi

# Try a few common verification methods available in minimal images.
for i in 1 2 3; do
    PAGE_CONTENT=$(kubectl -n init-container exec "$POD_NAME" -- sh -c 'wget -qO- http://localhost 2>/dev/null || busybox wget -qO- http://localhost 2>/dev/null || cat /usr/share/nginx/html/index.html 2>/dev/null' || echo "")
    if [[ "$PAGE_CONTENT" == *"check this out!"* ]]; then
        echo "Content validation successful"
        exit 0
    fi
    sleep 2
done

echo "Content does not contain expected text after retries. Last result: $PAGE_CONTENT"
echo "Debug: Checking if index.html exists in the pod..."
kubectl -n init-container exec $POD_NAME -- ls -la /usr/share/nginx/html/
exit 1
