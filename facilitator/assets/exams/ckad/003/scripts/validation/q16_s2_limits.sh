#!/bin/bash
# Q16 Step 2: Verify Pod explicitly declares CPU and Memory limits AND requests with actual values
CPU_LIMIT=$(kubectl get pod limited-pod -n q16-quota -o jsonpath='{.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
MEM_LIMIT=$(kubectl get pod limited-pod -n q16-quota -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null)
CPU_REQ=$(kubectl get pod limited-pod -n q16-quota -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
MEM_REQ=$(kubectl get pod limited-pod -n q16-quota -o jsonpath='{.spec.containers[0].resources.requests.memory}' 2>/dev/null)

[ -n "$CPU_LIMIT" ] && [ -n "$MEM_LIMIT" ] && [ -n "$CPU_REQ" ] && [ -n "$MEM_REQ" ] && exit 0 || exit 1
