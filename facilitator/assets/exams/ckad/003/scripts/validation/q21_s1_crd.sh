#!/bin/bash
kubectl get crd widgets.apps.ckx.io >/dev/null 2>&1 || exit 1
GROUP=$(kubectl get crd widgets.apps.ckx.io -o jsonpath='{.spec.group}' 2>/dev/null)
KIND=$(kubectl get crd widgets.apps.ckx.io -o jsonpath='{.spec.names.kind}' 2>/dev/null)
SCOPE=$(kubectl get crd widgets.apps.ckx.io -o jsonpath='{.spec.scope}' 2>/dev/null)
IMAGE_TYPE=$(kubectl get crd widgets.apps.ckx.io -o jsonpath='{.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.image.type}' 2>/dev/null)
REPLICAS_TYPE=$(kubectl get crd widgets.apps.ckx.io -o jsonpath='{.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.replicas.type}' 2>/dev/null)
REQUIRED_FIELDS=$(kubectl get crd widgets.apps.ckx.io -o jsonpath='{.spec.versions[0].schema.openAPIV3Schema.properties.spec.required[*]}' 2>/dev/null)

[ "$GROUP" = "apps.ckx.io" ] && \
[ "$KIND" = "Widget" ] && \
[ "$SCOPE" = "Namespaced" ] && \
[ "$IMAGE_TYPE" = "string" ] && \
[ "$REPLICAS_TYPE" = "integer" ] && \
echo "$REQUIRED_FIELDS" | grep -q 'image' && \
echo "$REQUIRED_FIELDS" | grep -q 'replicas' && exit 0 || exit 1
