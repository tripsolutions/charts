{{/* 
App version, image tag and all that jazz
*/}}

{{ define "companies.releaseName" -}}
{{- if or (hasPrefix "companies-" .Release.Name) (eq "companies" .Release.Name) -}}
{{ .Release.Name }}
{{- else if or (hasPrefix "agency-" .Release.Name) (eq "agency" .Release.Name) -}}
companies{{ trimPrefix "agency" .Release.Name }}
{{- else }}
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
{{- if hasPrefix (print .Values.db.teamId "-") (include "companies.releaseName" .) -}}
{{- include "companies.releaseName" . -}} -cluster
{{- else -}}
{{- .Values.db.teamId -}} - {{- include "companies.releaseName" . -}} -cluster
{{- end -}}
{{- end -}}
