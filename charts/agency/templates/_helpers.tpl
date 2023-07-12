{{/* 
App version, image tag and all that jazz
*/}}

{{ define "agency.releaseName" -}}
{{- if or (hasPrefix "agency-" .Release.Name) (eq "agency" .Release.Name) (not .Values.companies.enabled) -}}
{{ .Release.Name }}
{{- else -}}
agency-{{ .Release.Name }}
{{- end -}}
{{- end -}}

{{ define "agency.appVersion" -}}
{{ .Values.version | default .Chart.AppVersion }}
{{- end }}

{{ define "agency.imageTag" -}}
{{ .Values.image.tag | default (print "v" (include "agency.appVersion" .)) }}
{{- end }}

{{ define "agency.serverImageTag" -}}
{{ .Values.image.serverTag | default (include "agency.imageTag" .) }}
{{- end }}

{{ define "agency.clientImageTag" -}}
{{ .Values.image.clientTag | default (include "agency.imageTag" .) }}
{{- end }}

{{ define "agency.rescheckImageTag" -}}
{{ .Values.image.rescheckTag | default (include "agency.clientImageTag" .) }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "agency.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "agency.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Values.version | default .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
env: {{ .Values.agency.env }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "agency.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Cluster name
*/}}
{{- define "agency.clusterName" -}}
{{- $releaseName := include "agency.releaseName" . -}}
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
Common agency pod definitions
*/}}
{{- define "agency.pod" }}
image: {{ .Values.image.registry -}} /agency/server: {{- include "agency.serverImageTag" . }}
imagePullPolicy: {{ .Values.image.pullPolicy }}
securityContext:
  allowPrivilegeEscalation: false
  runAsUser: 33
  runAsGroup: 33
volumeMounts:
- mountPath: /config
  name: config
  subPath: app
{{- if eq .Values.db.provider "cnpg" }}
- mountPath: /var/www/.postgresql/postgresql.crt
  name: ssl-cert
  subPath: tls.crt
  readOnly: true
- mountPath: /var/www/.postgresql/postgresql.key
  name: ssl-cert
  subPath: tls.key
  readOnly: true
- mountPath: /var/www/.postgresql/root.crt
  name: ssl-cert
  subPath: ca.crt
  readOnly: true
{{- end }}
env:
{{- if eq .Values.db.provider "zalando" }}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef: 
      name: agency.{{ include "agency.clusterName" . }}.credentials
      key: password
{{- end }}
- name: CONFIG_PATH
  value: /config/agency.ini
{{- end }}