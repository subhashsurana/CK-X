#!/bin/bash
kubectl create ns q6-blue-green
kubectl create deployment app-blue --image=nginx:1.24 -n q6-blue-green
kubectl create deployment app-green --image=nginx:1.25 -n q6-blue-green
kubectl label deployment app-blue version=v1 -n q6-blue-green
kubectl label deployment app-green version=v2 -n q6-blue-green
sleep 2
kubectl patch deployment app-blue -n q6-blue-green -p '{"spec":{"template":{"metadata":{"labels":{"version":"v1","app":"web"}}}}}'
kubectl patch deployment app-green -n q6-blue-green -p '{"spec":{"template":{"metadata":{"labels":{"version":"v2","app":"web"}}}}}'
kubectl create service clusterip app-service --tcp=80:80 -n q6-blue-green
kubectl patch service app-service -n q6-blue-green -p '{"spec":{"selector":{"app":"web","version":"v1"}}}'
