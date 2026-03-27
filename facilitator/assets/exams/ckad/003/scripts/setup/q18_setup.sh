#!/bin/bash
kubectl create ns q18-affinity
NODE=$(kubectl get nodes -o jsonpath='{.items[?(@.spec.taints==null)].metadata.name}' | awk '{print $1}')
if [ -z "$NODE" ]; then
  NODE=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
fi
kubectl taint nodes $NODE type=batch:NoSchedule --overwrite
kubectl label nodes $NODE disktype=ssd --overwrite
