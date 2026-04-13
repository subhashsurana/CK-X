#!/bin/bash
kubectl get crd widgets.platform.example.com >/dev/null 2>&1 || { echo "Widget CRD not found"; exit 1; }
echo "Widget CRD exists"; exit 0
