#!/bin/bash
kubectl create ns q15-cross-ns
kubectl create ns q15-backend
kubectl create deployment backend --image=nginx -n q15-backend
kubectl create service clusterip backend-svc --tcp=8080:80 -n q15-backend
