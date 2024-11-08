#!/bin/bash +e

helm repo add linkerd https://helm.linkerd.io/stable

helm upgrade --install linkerd linkerd/linkerd-crds -n linkerd
