#!/usr/bin/env bash

set -eo pipefail

helm repo add fluxcd https://charts.fluxcd.io

helm upgrade -i flux fluxcd/flux --wait \
  --namespace fluxcd \
  --set registry.pollInterval=1m \
  --set git.pollInterval=1m \
  --set git.secretName="${GIT_SECRET_NAME:-}" \
  --set git.url="${GIT_URL}"

kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/helm-v3-dev/deploy/flux-helm-release-crd.yaml

helm upgrade -i helm-operator fluxcd/helm-operator --wait \
  --namespace fluxcd \
  --set git.ssh.secretName="${GIT_SECRET_NAME:-}" \
  --set git.pollInterval=1m \
  --set chartsSyncInterval=1m \
  --set configureRepositories.enable=true \
  --set configureRepositories.repositories[0].name=stable \
  --set configureRepositories.repositories[0].url=https://kubernetes-charts.storage.googleapis.com \
  --set configureRepositories.repositories[1].name=stable \
  --set configureRepositories.repositories[1].url=https://kubernetes-charts.storage.googleapis.com \
  --set extraEnvs[0].name=HELM_VERSION \
  --set extraEnvs[0].value=v3 \
  --set image.repository=docker.io/fluxcd/helm-operator-prerelease \
  --set image.tag=helm-v3-dev-f2ad4dfc
