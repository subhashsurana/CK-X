#!/bin/bash
kubectl create ns q7-canary
kubectl create deployment app-stable --image=nginx:1.24 --replicas=4 -n q7-canary
kubectl patch deployment app-stable -n q7-canary -p '{"spec":{"template":{"metadata":{"labels":{"app":"frontend","track":"stable"}}}}}'
kubectl create service clusterip app-svc --tcp=80:80 -n q7-canary
kubectl patch service app-svc -n q7-canary -p '{"spec":{"selector":{"app":"frontend"}}}'
