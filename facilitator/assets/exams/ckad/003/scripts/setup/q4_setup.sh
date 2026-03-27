#!/bin/bash
kubectl create ns q4-helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install my-release bitnami/nginx --version 15.0.0 -n q4-helm
