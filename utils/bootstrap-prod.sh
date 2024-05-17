#!/usr/bin/env bash

cd charts/argocd

helm upgrade --install --create-namespace --dependency-update argocd-infrastructure . -n argocd-infrastructure -f ./values.yaml -f ./values-production.yaml

kubectl apply -f ../../prod/_self.yaml
