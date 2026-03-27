#!/bin/bash
kubectl get ns q8-security >/dev/null 2>&1 && exit 0 || exit 1
