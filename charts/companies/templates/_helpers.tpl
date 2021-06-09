{{/* 
App version, image tag and all that jazz
*/}}

{{ define "appVersion" -}}
{{ .Values.version | default .Chart.AppVersion }}
{{- end }}

{{ define "imageTag" -}}
{{ .Values.image.tag | default .Values.version | default .Chart.AppVersion }}
{{- end }}

{{ define "serverImageTag" -}}
{{ .Values.image.serverTag | default .Values.image.tag | default .Values.version | default .Chart.AppVersion }}
{{- end }}

{{ define "clientImageTag" -}}
{{ .Values.image.clientTag | default .Values.image.tag | default .Values.version | default .Chart.AppVersion }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Values.version | default .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
env: {{ .Values.companies.env }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Cluster name
*/}}
{{- define "clusterName" -}}
{{- if hasPrefix (print .Values.db.teamId "-") .Release.Name  -}}
{{- .Release.Name -}} -cluster
{{- else -}}
{{- .Values.db.teamId -}} - {{- .Release.Name -}} -cluster
{{- end -}}
{{- end -}}