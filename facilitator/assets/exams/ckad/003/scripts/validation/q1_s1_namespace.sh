#!/bin/bash
kubectl get ns q1-sidecar >/dev/null 2>&1 && exit 0 || exit 1
