#!/bin/bash
GROUP=$(kubectl get crd widgets.platform.example.com -o jsonpath='{.spec.group}' 2>/dev/null)
KIND=$(kubectl get crd widgets.platform.example.com -o jsonpath='{.spec.names.kind}' 2>/dev/null)
PLURAL=$(kubectl get crd widgets.platform.example.com -o jsonpath='{.spec.names.plural}' 2>/dev/null)
VERSION=$(kubectl get crd widgets.platform.example.com -o jsonpath='{.spec.versions[?(@.name=="v1")].name}' 2>/dev/null)
SERVED=$(kubectl get crd widgets.platform.example.com -o jsonpath='{.spec.versions[?(@.name=="v1")].served}' 2>/dev/null)
STORAGE=$(kubectl get crd widgets.platform.example.com -o jsonpath='{.spec.versions[?(@.name=="v1")].storage}' 2>/dev/null)
if [[ "$GROUP" != "platform.example.com" || "$KIND" != "Widget" || "$PLURAL" != "widgets" || "$VERSION" != "v1" || "$SERVED" != "true" || "$STORAGE" != "true" ]]; then
  echo "Widget CRD spec is invalid"; exit 1
fi
echo "Widget CRD spec is correct"; exit 0
