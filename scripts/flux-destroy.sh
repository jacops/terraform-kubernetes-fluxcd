#!/usr/bin/env bash

set -eo pipefail

helm delete flux --namespace fluxcd
helm delete helm-operator --namespace fluxcd

kubectl delete -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/flux-helm-release-crd.yaml
