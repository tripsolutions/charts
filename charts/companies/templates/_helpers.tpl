{{/* 
App version, image tag and all that jazz
*/}}

{{ define "companies.releaseName" -}}
{{- if or (hasPrefix "companies-" .Release.Name) (eq "companies" .Release.Name) -}}
{{ .Release.Name }}
{{- else if or (hasPrefix "agency-" .Release.Name) (eq "agency" .Release.Name) -}}
companies{{ trimPrefix "agency" .Release.Name }}
{{- else -}}
companies-{{ .Release.Name }}
{{- end -}}
{{-  end }}

{{ define "companies.appVersion" -}}
{{ .Values.version | default .Chart.AppVersion }}
{{- end }}

{{ define "companies.imageTag" -}}
{{ .Values.image.tag | default (print "v" (include "companies.appVersion" .)) }}
{{- end }}

{{ define "companies.serverImageTag" -}}
{{ .Values.image.serverTag | default (include "companies.imageTag" .) }}
{{- end }}

{{ define "companies.clientImageTag" -}}
{{ .Values.image.clientTag | default (include "companies.imageTag" .) }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "companies.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "companies.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Values.version | default .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
env: {{ .Values.companies.env }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "companies.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Cluster name
*/}}
{{- define "companies.clusterName" -}}
{{- $releaseName := include "companies.releaseName" . -}}
{{- if or 
    (hasPrefix (print .Values.db.teamId "-") $releaseName) 
    (eq .Values.db.teamId $releaseName)
    -}}
{{- $releaseName -}} -cluster
{{- else -}}
{{- .Values.db.teamId -}} - {{- $releaseName -}} -cluster
{{- end -}}
{{- end -}}

{{- /* 
Common companies pod definitions
*/}}
{{- define "companies.pod" }}
image: {{ .Values.image.registry -}} /agency/companies-server: {{- include "companies.serverImageTag" . }}
imagePullPolicy: {{ .Values.image.pullPolicy }}
securityContext:
  allowPrivilegeEscalation: false
  runAsUser: 65534
  runAsGroup: 65534
volumeMounts:
- mountPath: /config
  name: config
  subPath: app
{{- if eq .Values.db.provider "cnpg" }}
- mountPath: /.postgresql/postgresql.crt
  name: ssl-cert
  subPath: tls.crt
  readonly: true
- mountPath: /.postgresql/postgresql.key
  name: ssl-cert
  subPath: tls.key
  readonly: true
- mountPath: /.postgresql/root.crt
  name: ssl-cert
  subPath: ca.crt
  readonly: true
{{- end }}
env:
- name: CONFIG_PATH
  value: /config/config.ini
{{- if eq .Values.db.provider "zalando" }}
- name: PG_PASS
  valueFrom:
    secretKeyRef: 
        name: companies.{{ include "companies.clusterName" . }}.credentials
        key: password
{{- end }}
{{- end }}