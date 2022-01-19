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
{{- if hasPrefix (print .Values.db.teamId "-") (include "agency.releaseName" .) -}}
{{- include "agency.releaseName" . -}} -cluster
{{- else -}}
{{- .Values.db.teamId -}} - {{- include "agency.releaseName" . -}} -cluster
{{- end -}}
{{- end -}}
