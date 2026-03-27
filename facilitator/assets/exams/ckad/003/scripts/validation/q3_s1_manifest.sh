#!/bin/bash
# Q3 Step 1: Verify converted manifest exists and uses batch/v1 (not v1beta1)
[ -f /tmp/new-cronjob.yaml ] || exit 1
grep -q 'apiVersion: batch/v1$' /tmp/new-cronjob.yaml && exit 0
# Also accept batch/v1 without trailing content (handles various YAML formatting)
grep 'apiVersion:' /tmp/new-cronjob.yaml | grep -q 'batch/v1' && ! grep 'apiVersion:' /tmp/new-cronjob.yaml | grep -q 'v1beta1' && exit 0 || exit 1
