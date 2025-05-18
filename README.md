> &#x26a0;&#xfe0f; &#x26a0;&#xfe0f; &#x26a0;&#xfe0f; Not for Production. This repository contains services which I am only experimenting with currently. Before using it, please consider reviewing everything, and also create a copy of this repository.

# Kubernetes Infrastructure

This project is a simple starting point to create a simple kubernetes cluster which can mainly be used to deploy web applications.


## Variables

Variables can be defined inside the `.env` file. The `.env.example` file contains all the variables which are used by the project.


## Services

The following services are included in this project (in order of their supposed installation order):
- [CertManager](https://cert-manager.io/): Handles automatic certificate renewal for services.
- [Traefik](https://traefik.io/traefik/): Ingress controller. Distributes requests based on their parameters (link host, path, etc.) amongs services.
- [Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/): A simple dashboard that can visualize your cluster.
- [Metrics Server](https://github.com/kubernetes-sigs/metrics-server): Exposes pod level metrics, that can be consumed by HPAs.
- [Prometheus](https://prometheus.io/): Aggregates statistics from the cluster. Only persists data for 1 day. **Federation needed** to an external server.
- [Linkerd](https://linkerd.io/): Service mesh. Exposes pod level traffic metrics using a sidecar conatiner. (Mainly used for it's tap feature.)
- [Vault](https://www.vaultproject.io/): Stores secrets like environment variables, certificates, etc...
- [ArgoCD](https://argoproj.github.io/cd/): Continous Delivery platform. Also used to visualize project resources.


Services which expose a web UI can be reached through the `https://<service-name>.<KUBE_DOMAIN>` endpoint. \
These are (with `kube.example.com` as `$KUBE_DOMAIN`):
- Traefik: `traefik.kube.example.com`
- Kubernetes Dashboard: `dashboard.kube.example.com`
- Prometheus: `prometheus.kube.example.com`
- Linkerd: `linkerd.kube.example.com`
- Vault: `vault.kube.example.com`
- ArgoCD: `argo.kube.example.com`


## Usage

To use this repo, you will need a [Kubernetes](https://kubernetes.io/) cluster to deploy the applications onto. You will also need the [Helm](https://helm.sh/), [Kubectl](https://kubernetes.io/docs/reference/kubectl/) and Envsubst tools installed on your local machine.

Before installing, you need to generate linkerd certificates (if you are using the Linkerd service). To do this, install [Step](https://smallstep.com/docs/step-cli/installation/), and generate certificates using the `step certificate create root.linkerd.cluster.local ca.crt ca.key --profile root-ca --no-password --insecure` command.

To get started installing services, simply execute the `installOrUpgrade.sh` script. It will handle the initial installation and the upgrade process of the defined services.  

To view the default administrator password, use the `kubectl -n argo get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d` command.