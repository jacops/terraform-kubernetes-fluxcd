#!/usr/bin/env bash

set -eo pipefail

VALUES_DIRECTORY=/tmp

FLUX_YAML_VALUES_FILE="${VALUES_DIRECTORY}/flux-values.yaml"
FLUX_YAML_CUSTOM_VALUES_FILE="${VALUES_DIRECTORY}/flux-custom-values.yaml"
echo "${FLUX_YAML_VALUES}" > "${FLUX_YAML_VALUES_FILE}"
echo "${FLUX_YAML_CUSTOM_VALUES}" > "${FLUX_YAML_CUSTOM_VALUES_FILE}"

HELM_OPERATOR_YAML_VALUES_FILE="${VALUES_DIRECTORY}/helm-operator-values.yaml"
HELM_OPERATOR_YAML_CUSTOM_VALUES_FILE="${VALUES_DIRECTORY}/helm-operator-custom-values.yaml"
echo "${HELM_OPERATOR_YAML_VALUES}" > "${HELM_OPERATOR_YAML_VALUES_FILE}"
echo "${HELM_OPERATOR_YAML_CUSTOM_VALUES}" > "${HELM_OPERATOR_YAML_CUSTOM_VALUES_FILE}"

helm repo add fluxcd https://charts.fluxcd.io

helm upgrade -i flux fluxcd/flux \
  --wait \
  --namespace fluxcd \
  --version "${FLUX_CHART_VERSION}" \
  --values "${FLUX_YAML_VALUES_FILE}" \
  --values "${FLUX_YAML_CUSTOM_VALUES_FILE}"

helm upgrade -i helm-operator fluxcd/helm-operator \
  --wait \
  --namespace fluxcd \
  --version "${HELM_OPERATOR_CHART_VERSION}" \
  --values "${HELM_OPERATOR_YAML_VALUES_FILE}" \
  --values "${HELM_OPERATOR_YAML_CUSTOM_VALUES_FILE}"

#rm -f \
#  "${FLUX_YAML_VALUES_FILE}" \
#  "${FLUX_YAML_CUSTOM_VALUES_FILE}" \
#  "${HELM_OPERATOR_YAML_VALUES_FILE}" \
#  "${HELM_OPERATOR_YAML_CUSTOM_VALUES_FILE}"
