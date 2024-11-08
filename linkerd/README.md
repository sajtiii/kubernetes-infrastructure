## Usage:

- Add the repo: `helm repo add linkerd https://helm.linkerd.io/stable`

- Install CRDs: `helm install linkerd linkerd/linkerd-crds -n linkerd`

- Install `step`: `brew install step`

- Generate certificates: `step certificate create root.linkerd.cluster.local ca.crt ca.key --profile root-ca --no-password --insecure`

- Store in kubernetes secret: `kubectl create secret tls linkerd-trust-anchor --cert=ca.crt --key=ca.key --namespace=linkerd`

- Store in kubernetes ConfigMap: `kubectl create configmap linkerd-identity-trust-roots --from-file=ca.crt --namespace=linkerd`

- Store in configmap: `kubectl create configmap linkerd-identity-trust-roots --from-file=ca-bundle.crt=ca.crt --namespace=linkerd`

- Upgrade: `helm upgrade linkerd . -n linkerd`

Helper command for rotating:
```bash
step certificate create root.linkerd.cluster.local ca.crt ca.key --profile root-ca --no-password --insecure && \
kubectl delete configmap linkerd-identity-trust-roots --namespace=linkerd --ignore-not-found && \
kubectl create configmap linkerd-identity-trust-roots --from-file=ca-bundle.crt=ca.crt --namespace=linkerd && \
kubectl delete secret linkerd-trust-anchor --namespace=linkerd --ignore-not-found && \
kubectl create secret tls linkerd-trust-anchor --cert=ca.crt --key=ca.key --namespace=linkerd
```