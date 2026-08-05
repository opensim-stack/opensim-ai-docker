#!/bin/sh
set -eu

# Exposed volumes
WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
CONFIG_DIR="${OPENSIM_DIR:-/config}"

# Default directories and filees
OPENSIM_DIR="${OPENSIM_DIR:-/opt/opensim}"
TEMPLATES_DIR="${TEMPLATES_DIR:-${OPENSIM_DIR}/docker/templates/opensim}"
BIN_DIR="${BIN_DIR:-${OPENSIM_DIR}/bin}"
BOT_STARTUP_FILE="${CONFIG_DIR}/bot_startup_commands.txt"
LOCAL_STARTUP_FILE="${CONFIG_DIR}/local_startup_commands.txt"
MERGED_STARTUP_FILE="${CONFIG_DIR}/startup_commands.txt"

# vvv remove
REGIONS_DIR="${REGIONS_DIR:-${BIN_DIR}/Regions}"

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
OPENSIM_LOGIN_MODEL="${OPENSIM_LOGIN_MODEL:-Ruth}"

OPENSIM_REGION_NAME_SAFE="$(printf '%s' "${OPENSIM_REGION_NAME}" | tr ' ' '_' | tr -cd 'A-Za-z0-9_-')"

export OPENSIM_HOSTNAME OPENSIM_REGION_NAME OPENSIM_REGION_X OPENSIM_REGION_Y \
    OPENSIM_REGION_PORT OPENSIM_ESTATE_NAME OPENSIM_ESTATE_OWNER_FIRST \
    OPENSIM_ESTATE_OWNER_LAST OPENSIM_ESTATE_OWNER_PASSWORD \
    OPENSIM_ESTATE_OWNER_EMAIL OPENSIM_ESTATE_OWNER_UUID OPENSIM_GRID_NAME \
    OPENSIM_GRID_NICK OPENSIM_WELCOME_MESSAGE OPENSIM_REGION_NAME_SAFE \
    OPENSIM_CONSOLE_MODE OPENSIM_CONSOLE_USER OPENSIM_CONSOLE_PASS \
    MARIADB_HOST MARIADB_DATABASE MARIADB_USER MARIADB_PASSWORD \
    OPENSIM_CREATE_BOT_USER OPENSIM_LOGIN_FIRSTNAME OPENSIM_LOGIN_LASTNAME \
    OPENSIM_LOGIN_PASSWORD OPENSIM_LOGIN_EMAIL OPENSIM_LOGIN_UUID OPENSIM_LOGIN_MODEL

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

mkdir -p "${WORKSPACE_DIR}" "${CONFIG_DIR}"

#
# TODO deal with below file by file so any can be deleted, but others
# are left alone. For now, just copy everything from the templates directory to the config directory if the config directory is empty.
# 

# If config directory is empty, copy default configs from templates.
if [ -z "$(find ${CONFIG_DIR} -mindepth 1 -maxdepth 1)" ]; then
    printf '[init] Base configuration is empty, populating.\n'

    mkdir -p "${CONFIG_DIR}/config-include" "${CONFIG_DIR}/Regions"

    # Copy anything from the actual OpenSim bin directory to the config directory, if it exists. And only if the source is not a symlink, and only if it contains files.
    if [ -d "${BIN_DIR}/config-include"  -a ! -L "${BIN_DIR}/config-includddddddddddddddddddddddddddde" -a -n "$(find ${BIN_DIR}/config-include -mindepth 1 -maxdepth 1)" ]; then
        printf '[init] Copying installed config-include files.\n'
        cp -Rp ${BIN_DIR}/config-include/* "${CONFIG_DIR}/config-include"
    fi
    if [ -d "${BIN_DIR}/Regions" -a ! -L "${BIN_DIR}/Regions" -a -n "$(find ${BIN_DIR}/Regions -mindepth 1 -maxdepth 1)" ]; then
        printf '[init] Copying installed region files.\n'
        cp -Rp ${BIN_DIR}/Regions/* "${CONFIG_DIR}/Regions"
    fi
    if [ -f "${BIN_DIR}/OpenSim.ini" -a ! -L "${BIN_DIR}/OpenSim.ini" ]; then
        printf '[init] Copying installed global config file.\n'
        cp "${BIN_DIR}/OpenSim.ini" "${CONFIG_DIR}"
    fi
    
    # Copy any templates from the docker templates directory to the config directory, overwriting any existing files and replace environment variables.
    for i in ${TEMPLATES_DIR}/*.ini; do
        printf "[init] Substituting ${i}.\n"
        envsubst '${OPENSIM_HOSTNAME}${OPENSIM_ESTATE_NAME}${OPENSIM_ESTATE_OWNER_FIRST}${OPENSIM_ESTATE_OWNER_LAST}${OPENSIM_ESTATE_OWNER_PASSWORD}${OPENSIM_ESTATE_OWNER_EMAIL}${OPENSIM_ESTATE_OWNER_UUID}${OPENSIM_CONSOLE_MODE}${OPENSIM_CONSOLE_USER}${OPENSIM_CONSOLE_PASS}${MARIADB_HOST}${MARIADB_DATABASE}${MARIADB_USER}${MARIADB_PASSWORD}${OPENSIM_GRID_NAME}${OPENSIM_GRID_NICK}${OPENSIM_WELCOME_MESSAGE}${OPENSIM_REGION_NAME_SAFE}' \
            < "${i}" > "${CONFIG_DIR}/$(basename "${i}")"
    done
    for i in ${TEMPLATES_DIR}/config-include/*.ini; do
        printf "[init] Substituting ${i}.\n"
        envsubst '${OPENSIM_HOSTNAME}${OPENSIM_ESTATE_NAME}${OPENSIM_ESTATE_OWNER_FIRST}${OPENSIM_ESTATE_OWNER_LAST}${OPENSIM_ESTATE_OWNER_PASSWORD}${OPENSIM_ESTATE_OWNER_EMAIL}${OPENSIM_ESTATE_OWNER_UUID}${OPENSIM_CONSOLE_MODE}${OPENSIM_CONSOLE_USER}${OPENSIM_CONSOLE_PASS}${MARIADB_HOST}${MARIADB_DATABASE}${MARIADB_USER}${MARIADB_PASSWORD}${OPENSIM_GRID_NAME}${OPENSIM_GRID_NICK}${OPENSIM_WELCOME_MESSAGE}${OPENSIM_REGION_NAME_SAFE}' \
            < "${i}" > "${CONFIG_DIR}/config-include/$(basename "${i}")"
    done
    
    printf "[init] Substituting Region.ini ${i}.\n"
    if [ -r /proc/sys/kernel/random/uuid ]; then
        OPENSIM_REGION_UUID="$(cat /proc/sys/kernel/random/uuid)"
    else
        OPENSIM_REGION_UUID="$(uuidgen | tr '[:upper:]' '[:lower:]')"
    fi
    export OPENSIM_REGION_UUID
    
    envsubst '${OPENSIM_REGION_NAME}${OPENSIM_REGION_UUID}${OPENSIM_REGION_X}${OPENSIM_REGION_Y}${OPENSIM_REGION_PORT}${OPENSIM_HOSTNAME}' \
        < "${TEMPLATES_DIR}/Regions/Region.ini" > "${CONFIG_DIR}/Regions/Region.ini"
fi


if [ "$(printf '%s' "${OPENSIM_CREATE_BOT_USER}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then
    if [ -z "${OPENSIM_LOGIN_UUID}" ]; then
        if [ -r /proc/sys/kernel/random/uuid ]; then
            OPENSIM_LOGIN_UUID="$(cat /proc/sys/kernel/random/uuid)"
        else
            OPENSIM_LOGIN_UUID="$(uuidgen | tr '[:upper:]' '[:lower:]')"
        fi
    fi

    touch "${BOT_STARTUP_FILE}"
    TMP_FILE="${BOT_STARTUP_FILE}.tmp.$$"
    # Replace previously managed bot bootstrap blocks (legacy and current formats).
    awk '
        BEGIN { in_block=0; skip_next=0 }
        /^# opensim-ai-docker bot bootstrap begin$/ { in_block=1; next }
        in_block && /^# opensim-ai-docker bot bootstrap end$/ { in_block=0; next }
        in_block { next }
        /^# opensim-ai-docker bot bootstrap$/ { skip_next=1; next }
        skip_next { skip_next=0; next }
        { print }
    ' "${BOT_STARTUP_FILE}" > "${TMP_FILE}"
    mv "${TMP_FILE}" "${BOT_STARTUP_FILE}"

    {
        printf '\n# opensim-ai-docker bot bootstrap begin\n'
        printf 'create user "%s" "%s" "%s" "%s" "%s" "%s"\n' \
            "${OPENSIM_LOGIN_FIRSTNAME}" "${OPENSIM_LOGIN_LASTNAME}" \
            "${OPENSIM_LOGIN_PASSWORD}" "${OPENSIM_LOGIN_EMAIL}" \
            "${OPENSIM_LOGIN_UUID}" "${OPENSIM_LOGIN_MODEL}"
        printf '# opensim-ai-docker bot bootstrap end\n'
    } >> "${BOT_STARTUP_FILE}"
    printf '[init] Updated startup command to create bot user %s %s.\n' "${OPENSIM_LOGIN_FIRSTNAME}" "${OPENSIM_LOGIN_LASTNAME}"
fi

rm -f "${MERGED_STARTUP_FILE}"
touch "${MERGED_STARTUP_FILE}"
if [ -f "${BOT_STARTUP_FILE}" ]; then
    cat "${BOT_STARTUP_FILE}" >> "${MERGED_STARTUP_FILE}"
fi
if [ -f "${LOCAL_STARTUP_FILE}" ]; then
    cat "${LOCAL_STARTUP_FILE}" >> "${MERGED_STARTUP_FILE}"
fi

printf '[init] Standalone config generation complete.\n'
