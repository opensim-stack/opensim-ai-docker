#!/bin/sh
set -eu

CONFIG_DIR="${CONFIG_DIR:-/config}"
TEMPLATES_DIR="/opt/opensim/docker/templates/osgrid"

# Required minimum details to join Hypergrid via OSGrid package
: "${OSGRID_REGION_NAME:?OSGRID_REGION_NAME is required}"
: "${OSGRID_REGION_UUID:?OSGRID_REGION_UUID is required}"
: "${OSGRID_REGION_LOCATION:?OSGRID_REGION_LOCATION is required (e.g. 1000,1000)}"
: "${OSGRID_EXTERNAL_HOSTNAME:?OSGRID_EXTERNAL_HOSTNAME is required}"

OSGRID_INTERNAL_PORT="${OSGRID_INTERNAL_PORT:-9000}"

OPENSIM_ESTATE_NAME="${OPENSIM_ESTATE_NAME:-My Estate}"
OPENSIM_ESTATE_OWNER_FIRST="${OPENSIM_ESTATE_OWNER_FIRST:-Admin}"
OPENSIM_ESTATE_OWNER_LAST="${OPENSIM_ESTATE_OWNER_LAST:-User}"
OPENSIM_ESTATE_OWNER_PASSWORD="${OPENSIM_ESTATE_OWNER_PASSWORD:-changeme}"
OPENSIM_ESTATE_OWNER_EMAIL="${OPENSIM_ESTATE_OWNER_EMAIL:-admin@example.com}"
OPENSIM_ESTATE_OWNER_UUID="${OPENSIM_ESTATE_OWNER_UUID:-00000000-0000-0000-0000-000000000000}"
OPENSIM_GRID_NAME="${OPENSIM_GRID_NAME:-OSGrid Region}"
OPENSIM_GRID_NICK="${OPENSIM_GRID_NICK:-osgrid}"
OPENSIM_WELCOME_MESSAGE="${OPENSIM_WELCOME_MESSAGE:-Welcome to OSGrid!}"
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
OPENSIM_LOGIN_MODEL="${OPENSIM_LOGIN_MODEL:-Admin User}"

OSGRID_REGION_NAME_SAFE="$(printf '%s' "${OSGRID_REGION_NAME}" | tr ' ' '_' | tr -cd 'A-Za-z0-9_-')"

export OPENSIM_ESTATE_NAME OPENSIM_ESTATE_OWNER_FIRST OPENSIM_ESTATE_OWNER_LAST \
    OPENSIM_ESTATE_OWNER_PASSWORD OPENSIM_ESTATE_OWNER_EMAIL OPENSIM_ESTATE_OWNER_UUID \
    OPENSIM_GRID_NAME OPENSIM_GRID_NICK OPENSIM_WELCOME_MESSAGE \
    OPENSIM_CONSOLE_MODE OPENSIM_CONSOLE_USER OPENSIM_CONSOLE_PASS \
    MARIADB_HOST MARIADB_DATABASE MARIADB_USER MARIADB_PASSWORD OSGRID_REGION_NAME_SAFE \
    OPENSIM_CREATE_BOT_USER OPENSIM_LOGIN_FIRSTNAME OPENSIM_LOGIN_LASTNAME \
    OPENSIM_LOGIN_PASSWORD OPENSIM_LOGIN_EMAIL OPENSIM_LOGIN_UUID OPENSIM_LOGIN_MODEL

printf '[init-osgrid] Waiting for MariaDB at %s...\n' "${MARIADB_HOST}"
attempts=0
until mariadb-admin ping -h "${MARIADB_HOST}" -u "${MARIADB_USER}" "--password=${MARIADB_PASSWORD}" --silent 2>/dev/null; do
    attempts=$((attempts + 1))
    if [ "${attempts}" -ge 60 ]; then
        printf '[init-osgrid] ERROR: MariaDB did not become ready after 3 minutes.\n' >&2
        exit 1
    fi
    sleep 3
done
printf '[init-osgrid] MariaDB is ready.\n'

export OSGRID_REGION_NAME OSGRID_REGION_UUID OSGRID_REGION_LOCATION OSGRID_EXTERNAL_HOSTNAME OSGRID_INTERNAL_PORT

mkdir -p "${CONFIG_DIR}/Regions" "${CONFIG_DIR}/config-include"

envsubst '${OSGRID_EXTERNAL_HOSTNAME}${OSGRID_INTERNAL_PORT}${OPENSIM_ESTATE_NAME}${OPENSIM_ESTATE_OWNER_FIRST}${OPENSIM_ESTATE_OWNER_LAST}${OPENSIM_ESTATE_OWNER_PASSWORD}${OPENSIM_ESTATE_OWNER_EMAIL}${OPENSIM_ESTATE_OWNER_UUID}${OPENSIM_CONSOLE_MODE}${OPENSIM_CONSOLE_USER}${OPENSIM_CONSOLE_PASS}' \
    < "${TEMPLATES_DIR}/OpenSim.ini" > "${CONFIG_DIR}/OpenSim.ini"

envsubst '${MARIADB_HOST}${MARIADB_DATABASE}${MARIADB_USER}${MARIADB_PASSWORD}${OSGRID_REGION_NAME_SAFE}${OPENSIM_WELCOME_MESSAGE}${OPENSIM_GRID_NAME}${OPENSIM_GRID_NICK}' \
    < "${TEMPLATES_DIR}/StandaloneCommon.ini" > "${CONFIG_DIR}/config-include/StandaloneCommon.ini"

envsubst '${OSGRID_REGION_NAME}${OSGRID_REGION_UUID}${OSGRID_REGION_LOCATION}${OSGRID_EXTERNAL_HOSTNAME}${OSGRID_INTERNAL_PORT}' \
    < "${TEMPLATES_DIR}/Region.ini" > "${CONFIG_DIR}/Regions/Region.ini"

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
    TMP_FILE="${STARTUP_FILE}.tmp.$$"
    # Replace previously managed bot bootstrap blocks (legacy and current formats).
    awk '
        BEGIN { in_block=0; skip_next=0 }
        /^# opensim-ai-docker bot bootstrap begin$/ { in_block=1; next }
        in_block && /^# opensim-ai-docker bot bootstrap end$/ { in_block=0; next }
        in_block { next }
        /^# opensim-ai-docker bot bootstrap$/ { skip_next=1; next }
        skip_next { skip_next=0; next }
        { print }
    ' "${STARTUP_FILE}" > "${TMP_FILE}"
    mv "${TMP_FILE}" "${STARTUP_FILE}"

    {
        printf '\n# opensim-ai-docker bot bootstrap begin\n'
        printf 'create user "%s" "%s" "%s" "%s" "%s" "%s"\n' \
            "${OPENSIM_LOGIN_FIRSTNAME}" "${OPENSIM_LOGIN_LASTNAME}" \
            "${OPENSIM_LOGIN_PASSWORD}" "${OPENSIM_LOGIN_EMAIL}" \
            "${OPENSIM_LOGIN_UUID}" "${OPENSIM_LOGIN_MODEL}"
        printf '# opensim-ai-docker bot bootstrap end\n'
    } >> "${STARTUP_FILE}"
    printf '[init-osgrid] Updated startup command to create bot user %s %s.\n' "${OPENSIM_LOGIN_FIRSTNAME}" "${OPENSIM_LOGIN_LASTNAME}"
fi

printf '[init-osgrid] Generated Regions/Region.ini for OSGrid mode.\n'
