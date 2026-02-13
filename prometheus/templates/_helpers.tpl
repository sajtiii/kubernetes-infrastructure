{{- define "ingressroute" -}}
{{- if .hostname }}
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: {{ .name }}
spec:
  entryPoints:
    - websecure
  routes:
    - kind: Rule
      match: Host(`{{ .hostname }}`)
      {{- if .allowedIps }}
      middlewares:
        - name: {{ .name }}-ipallowlist
      {{- end }}
      services:
        - name: {{ .serviceName }}
          port: {{ .servicePort }}
  tls:
    secretName: {{ .hostname }}-tls
{{- end }}
{{- end -}}

{{- define "certificate" -}}
{{- if .hostname }}
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: {{ .hostname }}-tls
spec:
  secretName: {{ .hostname }}-tls
  dnsNames:
    - {{ .hostname }}
  issuerRef:
    name: letsencrypt
    kind: ClusterIssuer
{{- end }}
{{- end -}}

{{- define "ipallowlist" -}}
{{- if .allowedIps }}
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: {{ .name }}-ipallowlist
spec:
  ipAllowList:
    sourceRange:
    {{- range .allowedIps }}
      - {{ . }}
    {{- end }}
{{- end }}
{{- end -}}
