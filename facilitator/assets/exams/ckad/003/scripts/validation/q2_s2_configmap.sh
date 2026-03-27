#!/bin/bash
# Q2 Step 2: Verify ConfigMap has correct data (PORT=8080, THEME=dark)
kubectl get cm app-config -n q2-config -o jsonpath='{.data.PORT}' | grep -q '8080' && \
kubectl get cm app-config -n q2-config -o jsonpath='{.data.THEME}' | grep -q 'dark' && exit 0 || exit 1
