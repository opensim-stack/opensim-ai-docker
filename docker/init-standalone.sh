#!/bin/sh
set -eu

CONFIG_DIR="${CONFIG_DIR:-/config}"
TEMPLATES_DIR="/opt/opensim/docker/templates"

OPENSIM_HOSTNAME="${OPENSIM_HOSTNAME:-127.0.0.1}"
OPENSIM_REGION_NAME="${OPENSIM_REGION_NAME:-Welcome Island}"
OPENSIM_REGION_X="${OPENSIM_REGION_X:-1000}"
OPENSIM_REGION_Y="${OPENSIM_REGION_Y:-1000}"
OPENSIM_REGION_PORT="${OPENSIM_REGION_PORT:-9000}"
OPENSIM_ESTATE_NAME="${OPENSIM_ESTATE_NAME:-My Estate}"
OPENSIM_ESTATE_OWNER_FIRST="${OPENSIM_ESTATE_OWNER_FIRST:-Admin}"
OPENSIM_ESTATE_OWNER_LAST="${OPENSIM_ESTATE_OWNER_LAST:-User}"
OPENSIM_ESTATE_OWNER_PASSWORD="${OPENSIM_ESTATE_OWNER_PASSWORD:-changeme}"
OPENSIM_ESTATE_OWNER_EMAIL="${OPENSIM_ESTATE_OWNER_EMAIL:-admin@example.com}"
OPENSIM_ESTATE_OWNER_UUID="${OPENSIM_ESTATE_OWNER_UUID:-00000000-0000-0000-0000-000000000000}"
OPENSIM_GRID_NAME="${OPENSIM_GRID_NAME:-My OpenSim Grid}"
OPENSIM_GRID_NICK="${OPENSIM_GRID_NICK:-opensimgrid}"
OPENSIM_WELCOME_MESSAGE="${OPENSIM_WELCOME_MESSAGE:-Welcome to My OpenSim Grid!}"
OPENSIM_CONSOLE_MODE="${OPENSIM_CONSOLE_MODE:-rest}"
OPENSIM_CONSOLE_USER="${OPENSIM_CONSOLE_USER:-ConsoleUser}"
OPENSIM_CONSOLE_PASS="${OPENSIM_CONSOLE_PASS:-ConsolePass}"
MARIADB_HOST="${MARIADB_HOST:-mariadb}"
MARIADB_DATABASE="${MARIADB_DATABASE:-opensim}"
MARIADB_USER="${MARIADB_USER:-opensim}"
MARIADB_PASSWORD="${MARIADB_PASSWORD:-opensimpassword}"
OPENSIM_CREATE_BOT_USER="${OPENSIM_CREATE_BOT_USER:-true}"
OPENSIM_LOGIN_FIRSTNAME="${OPENSIM_LOGIN_FIRSTNAME:-Bot}"
OPENSIM_LOGIN_LASTNAME="${OPENSIM_LOGIN_LASTNAME:-User}"
OPENSIM_LOGIN_PASSWORD="${OPENSIM_LOGIN_PASSWORD:-botpassword}"
OPENSIM_LOGIN_EMAIL="${OPENSIM_LOGIN_EMAIL:-bot@example.com}"
OPENSIM_LOGIN_UUID="${OPENSIM_LOGIN_UUID:-}"

OPENSIM_REGION_NAME_SAFE="$(printf '%s' "${OPENSIM_REGION_NAME}" | tr ' ' '_' | tr -cd 'A-Za-z0-9_-')"

export OPENSIM_HOSTNAME OPENSIM_REGION_NAME OPENSIM_REGION_X OPENSIM_REGION_Y \
    OPENSIM_REGION_PORT OPENSIM_ESTATE_NAME OPENSIM_ESTATE_OWNER_FIRST \
    OPENSIM_ESTATE_OWNER_LAST OPENSIM_ESTATE_OWNER_PASSWORD \
    OPENSIM_ESTATE_OWNER_EMAIL OPENSIM_ESTATE_OWNER_UUID OPENSIM_GRID_NAME \
    OPENSIM_GRID_NICK OPENSIM_WELCOME_MESSAGE OPENSIM_REGION_NAME_SAFE \
    OPENSIM_CONSOLE_MODE OPENSIM_CONSOLE_USER OPENSIM_CONSOLE_PASS \
    MARIADB_HOST MARIADB_DATABASE MARIADB_USER MARIADB_PASSWORD \
    OPENSIM_CREATE_BOT_USER OPENSIM_LOGIN_FIRSTNAME OPENSIM_LOGIN_LASTNAME \
    OPENSIM_LOGIN_PASSWORD OPENSIM_LOGIN_EMAIL OPENSIM_LOGIN_UUID

printf '[init] Waiting for MariaDB at %s...\n' "${MARIADB_HOST}"
attempts=0
until mariadb-admin ping -h "${MARIADB_HOST}" -u "${MARIADB_USER}" "--password=${MARIADB_PASSWORD}" --silent 2>/dev/null; do
    attempts=$((attempts + 1))
    if [ "${attempts}" -ge 60 ]; then
        printf '[init] ERROR: MariaDB did not become ready after 3 minutes.\n' >&2
        exit 1
    fi
    sleep 3
done
printf '[init] MariaDB is ready.\n'

mkdir -p "${CONFIG_DIR}/config-include" "${CONFIG_DIR}/Regions"

envsubst '${OPENSIM_HOSTNAME}${OPENSIM_ESTATE_NAME}${OPENSIM_ESTATE_OWNER_FIRST}${OPENSIM_ESTATE_OWNER_LAST}${OPENSIM_ESTATE_OWNER_PASSWORD}${OPENSIM_ESTATE_OWNER_EMAIL}${OPENSIM_ESTATE_OWNER_UUID}${OPENSIM_CONSOLE_MODE}${OPENSIM_CONSOLE_USER}${OPENSIM_CONSOLE_PASS}' \
    < "${TEMPLATES_DIR}/OpenSim.ini" > "${CONFIG_DIR}/OpenSim.ini"

envsubst '${MARIADB_HOST}${MARIADB_DATABASE}${MARIADB_USER}${MARIADB_PASSWORD}${OPENSIM_GRID_NAME}${OPENSIM_GRID_NICK}${OPENSIM_WELCOME_MESSAGE}${OPENSIM_REGION_NAME_SAFE}' \
    < "${TEMPLATES_DIR}/StandaloneCommon.ini" > "${CONFIG_DIR}/config-include/StandaloneCommon.ini"

if [ ! -f "${CONFIG_DIR}/Regions/Region.ini" ]; then
    if [ -r /proc/sys/kernel/random/uuid ]; then
        OPENSIM_REGION_UUID="$(cat /proc/sys/kernel/random/uuid)"
    else
        OPENSIM_REGION_UUID="$(uuidgen | tr '[:upper:]' '[:lower:]')"
    fi
    export OPENSIM_REGION_UUID

    envsubst '${OPENSIM_REGION_NAME}${OPENSIM_REGION_UUID}${OPENSIM_REGION_X}${OPENSIM_REGION_Y}${OPENSIM_REGION_PORT}${OPENSIM_HOSTNAME}' \
        < "${TEMPLATES_DIR}/Region.ini" > "${CONFIG_DIR}/Regions/Region.ini"
fi

STARTUP_FILE="${CONFIG_DIR}/startup_commands.txt"
if [ "$(printf '%s' "${OPENSIM_CREATE_BOT_USER}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then
    if [ -z "${OPENSIM_LOGIN_UUID}" ]; then
        if [ -r /proc/sys/kernel/random/uuid ]; then
            OPENSIM_LOGIN_UUID="$(cat /proc/sys/kernel/random/uuid)"
        else
            OPENSIM_LOGIN_UUID="$(uuidgen | tr '[:upper:]' '[:lower:]')"
        fi
    fi

    touch "${STARTUP_FILE}"
    if ! grep -Fq "# opensim-ai-docker bot bootstrap" "${STARTUP_FILE}" 2>/dev/null; then
        {
            printf '\n# opensim-ai-docker bot bootstrap\n'
            printf 'create user "%s" "%s" "%s" "%s" "%s"\n' \
                "${OPENSIM_LOGIN_FIRSTNAME}" "${OPENSIM_LOGIN_LASTNAME}" \
                "${OPENSIM_LOGIN_PASSWORD}" "${OPENSIM_LOGIN_EMAIL}" "${OPENSIM_LOGIN_UUID}"
        } >> "${STARTUP_FILE}"
        printf '[init] Added startup command to create bot user %s %s.\n' "${OPENSIM_LOGIN_FIRSTNAME}" "${OPENSIM_LOGIN_LASTNAME}"
    fi
fi

printf '[init] Standalone config generation complete.\n'
