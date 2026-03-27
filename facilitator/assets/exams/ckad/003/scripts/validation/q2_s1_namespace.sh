#!/bin/bash
kubectl get ns q2-config >/dev/null 2>&1 && exit 0 || exit 1
