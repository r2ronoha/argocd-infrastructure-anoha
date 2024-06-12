#!/usr/bin/env bash

set -e

function overrideChartYaml {
  if [[ -f "chaos/${ARGOCD_ENV_APPLICATION}/${ARGOCD_ENV_ENVIRONMENT}/${ARGOCD_ENV_CLUSTER_TYPE}/${ARGOCD_ENV_CLUSTER_REGION}/${ARGOCD_ENV_CLUSTER_NAME}/Chart.yaml" ]]; then
    cp "chaos/${ARGOCD_ENV_APPLICATION}/${ARGOCD_ENV_ENVIRONMENT}/${ARGOCD_ENV_CLUSTER_TYPE}/${ARGOCD_ENV_CLUSTER_REGION}/${ARGOCD_ENV_CLUSTER_NAME}/Chart.yaml" Chart.yaml
    return
  fi

  if [[ -f "chaos/${ARGOCD_ENV_APPLICATION}/${ARGOCD_ENV_ENVIRONMENT}/${ARGOCD_ENV_CLUSTER_TYPE}/${ARGOCD_ENV_CLUSTER_REGION}/Chart.yaml" ]]; then
    cp "chaos/${ARGOCD_ENV_APPLICATION}/${ARGOCD_ENV_ENVIRONMENT}/${ARGOCD_ENV_CLUSTER_TYPE}/${ARGOCD_ENV_CLUSTER_REGION}/Chart.yaml" Chart.yaml
    return
  fi

  if [[ -f "chaos/${ARGOCD_ENV_APPLICATION}/${ARGOCD_ENV_ENVIRONMENT}/${ARGOCD_ENV_CLUSTER_TYPE}/Chart.yaml" ]]; then
    cp "chaos/${ARGOCD_ENV_APPLICATION}/${ARGOCD_ENV_ENVIRONMENT}/${ARGOCD_ENV_CLUSTER_TYPE}/Chart.yaml" Chart.yaml
    return
  fi

  if [[ -f "chaos/${ARGOCD_ENV_APPLICATION}/${ARGOCD_ENV_ENVIRONMENT}/Chart.yaml" ]]; then
    cp "chaos/${ARGOCD_ENV_APPLICATION}/${ARGOCD_ENV_ENVIRONMENT}/Chart.yaml" Chart.yaml
    return
  fi

  if [[ -f "chaos/${ARGOCD_ENV_APPLICATION}/Chart.yaml" ]]; then
    cp "chaos/${ARGOCD_ENV_APPLICATION}/Chart.yaml" Chart.yaml
    return
  fi

  if [[ -f "chaos/Chart.yaml" ]]; then
    cp "chaos/Chart.yaml" Chart.yaml
    return
  fi
}

# Get proper Chart.yaml file from app hierarchical configuration
overrideChartYaml

# Get charts
export GITHUB_TOKEN=${WANDERA_VIEWER_TOKEN}
helm dependency update > /dev/null

# Fill in the app-specific hierarchy if some files or subdirectories are missing.
mkdir -p chaos/${ARGOCD_ENV_APPLICATION}/${ARGOCD_ENV_ENVIRONMENT}/${ARGOCD_ENV_CLUSTER_TYPE}/${ARGOCD_ENV_CLUSTER_REGION}/${ARGOCD_ENV_CLUSTER_NAME}
VALUES=( values chaos/values chaos/${ARGOCD_ENV_APPLICATION}/values chaos/${ARGOCD_ENV_APPLICATION}/${ARGOCD_ENV_ENVIRONMENT}/values chaos/${ARGOCD_ENV_APPLICATION}/${ARGOCD_ENV_ENVIRONMENT}/${ARGOCD_ENV_CLUSTER_TYPE}/values chaos/${ARGOCD_ENV_APPLICATION}/${ARGOCD_ENV_ENVIRONMENT}/${ARGOCD_ENV_CLUSTER_TYPE}/${ARGOCD_ENV_CLUSTER_REGION}/values chaos/${ARGOCD_ENV_APPLICATION}/${ARGOCD_ENV_ENVIRONMENT}/${ARGOCD_ENV_CLUSTER_TYPE}/${ARGOCD_ENV_CLUSTER_REGION}/${ARGOCD_ENV_CLUSTER_NAME}/values)
touch $(printf "%s.tmpl "  "${VALUES[@]}")

# Fill in the app-agnostic hierarchy if some files or subdirectories are missing.
CONFIG_PATH=../../config
mkdir -p ${CONFIG_PATH}/chaos/${ARGOCD_ENV_APPLICATION}/${ARGOCD_ENV_ENVIRONMENT}/${ARGOCD_ENV_CLUSTER_TYPE}/${ARGOCD_ENV_CLUSTER_REGION}/${ARGOCD_ENV_CLUSTER_NAME}
TEMPLATES=(${CONFIG_PATH}/template.tmpl ${CONFIG_PATH}/chaos/template.tmpl ${CONFIG_PATH}/chaos/${ARGOCD_ENV_APPLICATION}/template.tmpl ${CONFIG_PATH}/chaos/${ARGOCD_ENV_APPLICATION}/${ARGOCD_ENV_ENVIRONMENT}/template.tmpl ${CONFIG_PATH}/chaos/${ARGOCD_ENV_APPLICATION}/${ARGOCD_ENV_ENVIRONMENT}/${ARGOCD_ENV_CLUSTER_TYPE}/template.tmpl ${CONFIG_PATH}/chaos/${ARGOCD_ENV_APPLICATION}/${ARGOCD_ENV_ENVIRONMENT}/${ARGOCD_ENV_CLUSTER_TYPE}/${ARGOCD_ENV_CLUSTER_REGION}/template.tmpl ${CONFIG_PATH}/chaos/${ARGOCD_ENV_APPLICATION}/${ARGOCD_ENV_ENVIRONMENT}/${ARGOCD_ENV_CLUSTER_TYPE}/${ARGOCD_ENV_CLUSTER_REGION}/${ARGOCD_ENV_CLUSTER_NAME}/template.tmpl)
touch $(printf "%s "  "${TEMPLATES[@]}")

TEMPLATE_PARAMS="$(printf " -t %s "  "${TEMPLATES[@]}")"

# Render app-agnostic templates in value.yaml files.
for v in "${VALUES[@]}"; do
    gomplate -f ${v}.tmpl ${TEMPLATE_PARAMS} -o ${v}.yaml
done

# Render chart templates.
if [[ -n "${ARGOCD_APP_NAMESPACE}" ]]; then
  NAMESPACE_PARAM="--namespace ${ARGOCD_APP_NAMESPACE}"
else
  NAMESPACE_PARAM=""
fi

helm template --api-versions=${KUBE_API_VERSIONS} --kube-version=${KUBE_VERSION} ${ARGOCD_ENV_RELEASE_NAME:-wandera} ${NAMESPACE_PARAM} ${ARGOCD_ENV_HELM_ARGS} $(printf " -f %s.yaml "  "${VALUES[@]}") . > all.yaml

# kustomize
if [[ -f kustomization.yaml ]]; then
  kustomize build
else
  cat all.yaml
fi
