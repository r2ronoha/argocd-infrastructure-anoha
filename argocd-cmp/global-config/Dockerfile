FROM alpine:3.19.1

RUN apk update && apk add curl git bash

ENV YQ_VERSION=v4.43.1
RUN curl https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -Lo /usr/bin/yq && \
    chmod +x /usr/bin/yq

ENV GOMPLATE_VERSION=v3.11.7
RUN curl https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_linux-amd64 -Lo /usr/bin/gomplate && \
    chmod +x /usr/bin/gomplate

ENV HELM_VERSION=v3.15.4
RUN curl https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -Lo /tmp/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -zxvf /tmp/helm-${HELM_VERSION}-linux-amd64.tar.gz -C /tmp && mv /tmp/linux-amd64/helm /usr/local/bin/helm && \
    helm plugin install https://github.com/wandera/helm-github --version 0.1.7

ENV KUSTOMIZE_VERSION=v5.4.1
RUN curl https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz -Lo /tmp/kustomize-${KUSTOMIZE_VERSION}-linux-amd64.tar.gz && \
    tar -zxvf /tmp/kustomize-${KUSTOMIZE_VERSION}-linux-amd64.tar.gz -C /tmp && mv /tmp/kustomize /usr/local/bin/kustomize

COPY plugin.yaml /home/argocd/cmp-server/config/plugin.yaml
COPY scripts /home/argocd/scripts
RUN chmod +x /home/argocd/scripts/*.sh
