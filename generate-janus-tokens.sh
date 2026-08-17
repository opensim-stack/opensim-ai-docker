#!/bin/sh
set -eu

TARGET_FILE="${1:-.env}"

new_uuid() {
    if command -v uuidgen >/dev/null 2>&1; then
        uuidgen | tr '[:upper:]' '[:lower:]'
    elif [ -r /proc/sys/kernel/random/uuid ]; then
        cat /proc/sys/kernel/random/uuid
    else
        # Fallback: timestamp-based token if uuidgen is unavailable.
        date +"token-%s-%N"
    fi
}

upsert_env_var() {
    key="$1"
    value="$2"

    if [ -f "${TARGET_FILE}" ] && grep -q "^${key}=" "${TARGET_FILE}"; then
        sed -i "s|^${key}=.*|${key}=${value}|" "${TARGET_FILE}"
    else
        printf '%s=%s\n' "${key}" "${value}" >> "${TARGET_FILE}"
    fi
}

if [ ! -f "${TARGET_FILE}" ] && [ -f .env.example ]; then
    cp .env.example "${TARGET_FILE}"
fi

api_token="$(new_uuid)"
admin_token="$(new_uuid)"

upsert_env_var "JANUS_API_TOKEN" "${api_token}"
upsert_env_var "JANUS_ADMIN_TOKEN" "${admin_token}"

printf 'Updated %s with one-off Janus tokens.\n' "${TARGET_FILE}"
printf 'JANUS_API_TOKEN=%s\n' "${api_token}"
printf 'JANUS_ADMIN_TOKEN=%s\n' "${admin_token}"
