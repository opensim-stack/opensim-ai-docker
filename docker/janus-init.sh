#!/bin/sh
set -eu

JANUS_TEMPLATE_DIR="${JANUS_TEMPLATE_DIR:-/opt/janus/etc/janus}"
JANUS_CONFIG_DIR="${JANUS_CONFIG_DIR:-/janus-config}"

JANUS_SERVER_NAME="${JANUS_SERVER_NAME:-GridVoice}"
JANUS_HTTP_ENABLE="${JANUS_HTTP_ENABLE:-true}"
JANUS_HTTP_PORT="${JANUS_HTTP_PORT:-14223}"
JANUS_HTTP_BASEPATH="${JANUS_HTTP_BASEPATH:-/voice}"
JANUS_HTTPS_ENABLE="${JANUS_HTTPS_ENABLE:-false}"
JANUS_HTTPS_PORT="${JANUS_HTTPS_PORT:-14224}"
JANUS_HTTP_ADMIN_ENABLE="${JANUS_HTTP_ADMIN_ENABLE:-true}"
JANUS_HTTP_ADMIN_PORT="${JANUS_HTTP_ADMIN_PORT:-14225}"
JANUS_HTTP_ADMIN_BASEPATH="${JANUS_HTTP_ADMIN_BASEPATH:-/voiceAdmin}"
JANUS_API_TOKEN="${JANUS_API_TOKEN:-change-me-api-token}"
JANUS_ADMIN_TOKEN="${JANUS_ADMIN_TOKEN:-change-me-admin-token}"

mkdir -p "${JANUS_CONFIG_DIR}"
cp -a "${JANUS_TEMPLATE_DIR}/." "${JANUS_CONFIG_DIR}/"

# Mirror the upstream os-webrtc-janus-docker substitutions for API/admin endpoints.
sed --in-place \
    -e "s/#*api_secret = \".*\"/api_secret = \"${JANUS_API_TOKEN}\"/" \
    -e "s/#*admin_secret = \".*\"/admin_secret = \"${JANUS_ADMIN_TOKEN}\"/" \
    -e "s/#*server_name = \".*\"/server_name = \"${JANUS_SERVER_NAME}\" /" \
    "${JANUS_CONFIG_DIR}/janus.jcfg"

sed --in-place \
    -e "s|#*http =.*#|http = ${JANUS_HTTP_ENABLE} #|" \
    -e "s|#*port =.*#|port = ${JANUS_HTTP_PORT} #|" \
    -e "s|#*base_path = \".*\"|base_path = \"${JANUS_HTTP_BASEPATH}\"|" \
    -e "s|#*https =.*#|https = ${JANUS_HTTPS_ENABLE} #|" \
    -e "s|#*http_port =.*#|http_port = ${JANUS_HTTPS_PORT} #|" \
    -e "s|#*admin_http =.*#|admin_http = ${JANUS_HTTP_ADMIN_ENABLE} #|" \
    -e "s|#*admin_port =.*#|admin_port = ${JANUS_HTTP_ADMIN_PORT} #|" \
    -e "s|#*admin_base_path = \".*\"|admin_base_path = \"${JANUS_HTTP_ADMIN_BASEPATH}\"|" \
    "${JANUS_CONFIG_DIR}/janus.transport.http.jcfg"

printf '[janus-init] Janus config generated in %s\n' "${JANUS_CONFIG_DIR}"
