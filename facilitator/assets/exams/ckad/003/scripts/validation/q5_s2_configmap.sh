#!/bin/bash
kubectl get cm -n q5-kustomize | grep -q 'web-config' && exit 0 || exit 1
