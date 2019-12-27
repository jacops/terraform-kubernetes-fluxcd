#!/usr/bin/env bash

set -exo pipefail

VALUES_DIRECTORY=/tmp
NAMESPACE=${NAMESPACE:-fluxcd}

YAML_VALUES_FILE="${VALUES_DIRECTORY}/${RELEASE_NAME}-values.yaml"
YAML_CUSTOM_VALUES_FILE="${VALUES_DIRECTORY}/${RELEASE_NAME}-custom-values.yaml"
echo "${YAML_VALUES}" > "${YAML_VALUES_FILE}"
echo "${YAML_CUSTOM_VALUES}" > "${YAML_CUSTOM_VALUES_FILE}"

helm repo add fluxcd https://charts.fluxcd.io

helm upgrade -i "${RELEASE_NAME}" "${CHART_NAME}" \
  --wait \
  --namespace "${NAMESPACE}" \
  --version "${CHART_VERSION}" \
  --values "${YAML_VALUES_FILE}" \
  --values "${YAML_CUSTOM_VALUES_FILE}"

rm -f \
  "${YAML_VALUES_FILE}" \
  "${YAML_CUSTOM_VALUES_FILE}"
