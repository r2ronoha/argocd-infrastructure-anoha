#!/usr/bin/env bash

cd charts/argocd

helm upgrade --install --create-namespace --dependency-update argocd . -n argocd -f ./values.yaml -f ./values-staging.yaml

kubectl apply -f ../../stage/_self.yaml
