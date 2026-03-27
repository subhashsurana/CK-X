#!/bin/bash
kubectl create ns q9-identity
kubectl run api-consumer --image=nginx:alpine -n q9-identity
