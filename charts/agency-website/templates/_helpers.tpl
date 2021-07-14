{{/* 
App version, image tag and all that jazz
*/}}

{{ define "appVersion" -}}
{{ $.Values.version | default $.Chart.AppVersion }}
{{- end }}

{{- define "image" -}}
{{- with $.Values.image -}}
image: {{ .registry -}} /
    {{- .name -}} : 
    {{- .tag | default $.Values.version | default $.Chart.AppVersion | toString }}
imagePullPolicy: {{ .pullPolicy }}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "labels" -}}
helm.sh/chart: {{ $.Chart.Name }}-{{ $.Chart.Version | replace "+" "_" }}
{{ include "selectorLabels" . }}
{{- if $.Chart.AppVersion }}
app.kubernetes.io/version: {{ $.Values.version | default $.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "selectorLabels" -}}
app.kubernetes.io/name: {{ $.Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

