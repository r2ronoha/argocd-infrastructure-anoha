#!/usr/bin/env bash

cd charts/argocd

helm upgrade --install --create-namespace --dependency-update argocd-infrastructure . -n argocd-infrastructure -f ./values.yaml -f ./values-sbox.yaml

kubectl apply -f ../../sbox/_self.yaml
