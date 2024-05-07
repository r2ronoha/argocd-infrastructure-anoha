{{- define "argocd.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "argocd.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "argocd.labels" -}}
helm.sh/chart: {{ include "argocd.chart" . }}
app.kubernetes.io/name: {{ include "argocd.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "argocd.additionalLabels" . }}
{{- end }}

{{/*
Additional labels
*/}}
{{- define "argocd.additionalLabels" -}}
jamf.com/environment: {{ .Values.cluster.environment | quote }}
jamf.com/owner: {{ .Values.cluster.owner | quote }}
{{- end }}
