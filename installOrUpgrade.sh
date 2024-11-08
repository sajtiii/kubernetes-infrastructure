#!/bin/bash -e

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 [all|<service1> <service2> ...]"
    exit
fi

# Check if required tools are installed
tools=(
    "helm"
    "kubectl"
    "envsubst"
)
for tool in "${tools[@]}"; do
    if [ ! command -v $tool &> /dev/null ]; then
        echo "$tool could not be found"
        exit
    fi
done

if [ -f .env ]; then
    set -a && source .env && set +a
fi

# Check if required env variables are set
required_env_vars=(
    "KUBE_DOMAIN"
    "LETSENCRYPT_EMAIL"
    "CLOUDFLARE_TOKEN"
    "GRAFANA_URL"
)
for env_var in "${required_env_vars[@]}"; do
    if [ -z "${!env_var}" ]; then
        echo "$env_var env is not set"
        exit
    fi
done

# Check if required files are present
required_files=(
    "ca.crt"
    "ca.key"
)
for file in "${required_files[@]}"; do
    if [ ! -f $file ]; then
        echo "$file could not be found"
        exit
    fi
done

# Set default values
export TRAEFIK_DASHBOARD_ALLOWED_IPS=${TRAEFIK_DASHBOARD_ALLOWED_IPS:-0.0.0.0/0}
export PROMETHEUS_ALLOWED_IPS=${PROMETHEUS_ALLOWED_IPS:-0.0.0.0/0}
export VAULT_UI_ALLOWED_IPS=${VAULT_UI_ALLOWED_IPS:-0.0.0.0/0}
export ARGO_ALLOWED_IPS=${ARGO_ALLOWED_IPS:-0.0.0.0/0}
export LINKERD_ALLOWED_IPS=${LINKERD_ALLOWED_IPS:-0.0.0.0/0}
export KUBERNETES_DASHBOARD_ALLOWED_IPS=${KUBERNETES_DASHBOARD_ALLOWED_IPS:-0.0.0.0/0}
export LINKERD_CA_CRT=$(cat ca.crt | sed -e 's/^/    /')
export LINKERD_CA_KEY=$(cat ca.key | sed -e 's/^/    /')

charts=(
    "certmanager"
    "traefik"
    "kubernetes-dashboard"
    "metrics"
    "linkerd"
    "vault"
    "argo"
)

for chart in "${charts[@]}"; do
    if [ "$@" != "all" ]; then
        if [[ "$@" != *$chart* ]]; then
            continue
        fi
    fi
    
    if [ -f $chart/values.template.yaml ]; then
        envsubst < $chart/values.template.yaml > $chart/values.yaml
    fi

    if [ ! -f "$chart/values.yaml" ]; then
        echo "$chart/values.yaml could not be found"
        exit
    fi
    
    if [ -f "$chart/requirements.sh" ]; then
        source $chart/requirements.sh
    fi

    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: $chart
  labels:
    name: $chart
EOF

    helm upgrade --install --dependency-update $chart ./$chart -n $chart
done