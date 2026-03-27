#!/bin/bash
kubectl get deploy library -n q13-storage -o jsonpath='{.spec.template.spec.volumes[0].persistentVolumeClaim.claimName}' | grep -q 'library-pvc' && exit 0 || exit 1
