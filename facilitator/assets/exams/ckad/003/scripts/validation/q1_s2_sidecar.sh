#!/bin/bash
kubectl get pod sidecar-pod -n q1-sidecar -o jsonpath='{.spec.initContainers[0].restartPolicy}' | grep -q Always && exit 0 || exit 1
