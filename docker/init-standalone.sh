#!/bin/sh
set -eu

# Exposed volumes
WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
CONFIG_DIR="${CONFIG_DIR:-/config}"

# Default directories and filees
OPENSIM_DIR="${OPENSIM_DIR:-/opt/opensim}"
TEMPLATES_DIR="${TEMPLATES_DIR:-${OPENSIM_DIR}/docker/templates/opensim}"
BIN_DIR="${BIN_DIR:-${OPENSIM_DIR}/bin}"
BOT_STARTUP_FILE="${CONFIG_DIR}/bot_startup_commands.txt"
REGION_STARTUP_FILE="${CONFIG_DIR}/region_startup_commands.txt"
INVENTORY_STARTUP_FILE="${CONFIG_DIR}/inventory_startup_commands.txt"
LOCAL_STARTUP_FILE="${CONFIG_DIR}/local_startup_commands.txt"
MERGED_STARTUP_FILE="${CONFIG_DIR}/startup_commands.txt"
DEFAULT_OAR_FILE="${DEFAULT_OAR_FILE:-${OPENSIM_DIR}/docker/data/OAR-Sandbox(1X1).tgz}"
DEFAULT_IAR_FILE="${DEFAULT_IAR_FILE:-${OPENSIM_DIR}/docker/data/Cube-Bot-IAR.iar}"

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
OPENSIM_WEBRTC_VOICE_ENABLED="${OPENSIM_WEBRTC_VOICE_ENABLED:-true}"
OPENSIM_JANUS_PUBLIC_HOST="${OPENSIM_JANUS_PUBLIC_HOST:-${OPENSIM_HOSTNAME}}"
JANUS_HTTP_PORT="${JANUS_HTTP_PORT:-14223}"
JANUS_HTTP_BASEPATH="${JANUS_HTTP_BASEPATH:-/voice}"
JANUS_HTTP_ADMIN_PORT="${JANUS_HTTP_ADMIN_PORT:-14225}"
JANUS_HTTP_ADMIN_BASEPATH="${JANUS_HTTP_ADMIN_BASEPATH:-/voiceAdmin}"
JANUS_API_TOKEN="${JANUS_API_TOKEN:-change-me-api-token}"
JANUS_ADMIN_TOKEN="${JANUS_ADMIN_TOKEN:-change-me-admin-token}"

OPENSIM_REGION_NAME_SAFE="$(printf '%s' "${OPENSIM_REGION_NAME}" | tr ' ' '_' | tr -cd 'A-Za-z0-9_-')"

export OPENSIM_HOSTNAME OPENSIM_REGION_NAME OPENSIM_REGION_X OPENSIM_REGION_Y \
    OPENSIM_REGION_PORT OPENSIM_ESTATE_NAME OPENSIM_ESTATE_OWNER_FIRST \
    OPENSIM_ESTATE_OWNER_LAST OPENSIM_ESTATE_OWNER_PASSWORD \
    OPENSIM_ESTATE_OWNER_EMAIL OPENSIM_ESTATE_OWNER_UUID OPENSIM_GRID_NAME \
    OPENSIM_GRID_NICK OPENSIM_WELCOME_MESSAGE OPENSIM_REGION_NAME_SAFE \
    OPENSIM_CONSOLE_MODE OPENSIM_CONSOLE_USER OPENSIM_CONSOLE_PASS \
    MARIADB_HOST MARIADB_DATABASE MARIADB_USER MARIADB_PASSWORD \
    OPENSIM_CREATE_BOT_USER OPENSIM_LOGIN_FIRSTNAME OPENSIM_LOGIN_LASTNAME \
    OPENSIM_LOGIN_PASSWORD OPENSIM_LOGIN_EMAIL OPENSIM_LOGIN_UUID OPENSIM_LOGIN_MODEL \
    OPENSIM_WEBRTC_VOICE_ENABLED OPENSIM_JANUS_PUBLIC_HOST JANUS_HTTP_PORT \
    JANUS_HTTP_BASEPATH JANUS_HTTP_ADMIN_PORT JANUS_HTTP_ADMIN_BASEPATH \
    JANUS_API_TOKEN JANUS_ADMIN_TOKEN

sql_escape() {
    printf "%s" "$1" | sed "s/'/''/g"
}

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

# If config directory is empty, copy default configs from templates.
if [ -z "$(find ${CONFIG_DIR} -mindepth 1 -maxdepth 1)" ]; then
    printf '[init] Base configuration is empty, populating.\n'

    mkdir -p "${CONFIG_DIR}/config-include" "${CONFIG_DIR}/Regions"

    # Copy anything from the actual OpenSim bin directory to the config directory, if it exists. And only if the source is not a symlink, and only if it contains files.
    if [ -d "${BIN_DIR}/config-include"  -a ! -L "${BIN_DIR}/config-include" -a -n "$(find ${BIN_DIR}/config-include -mindepth 1 -maxdepth 1)" ]; then
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
        envsubst '${OPENSIM_HOSTNAME}${OPENSIM_ESTATE_NAME}${OPENSIM_ESTATE_OWNER_FIRST}${OPENSIM_ESTATE_OWNER_LAST}${OPENSIM_ESTATE_OWNER_PASSWORD}${OPENSIM_ESTATE_OWNER_EMAIL}${OPENSIM_ESTATE_OWNER_UUID}${OPENSIM_CONSOLE_MODE}${OPENSIM_CONSOLE_USER}${OPENSIM_CONSOLE_PASS}${MARIADB_HOST}${MARIADB_DATABASE}${MARIADB_USER}${MARIADB_PASSWORD}${OPENSIM_GRID_NAME}${OPENSIM_GRID_NICK}${OPENSIM_WELCOME_MESSAGE}${OPENSIM_REGION_NAME_SAFE}${OPENSIM_WEBRTC_VOICE_ENABLED}${OPENSIM_JANUS_PUBLIC_HOST}${JANUS_HTTP_PORT}${JANUS_HTTP_BASEPATH}${JANUS_HTTP_ADMIN_PORT}${JANUS_HTTP_ADMIN_BASEPATH}${JANUS_API_TOKEN}${JANUS_ADMIN_TOKEN}' \
            < "${i}" > "${CONFIG_DIR}/$(basename "${i}")"
    done
    for i in ${TEMPLATES_DIR}/config-include/*.ini; do
        printf "[init] Substituting ${i}.\n"
        envsubst '${OPENSIM_HOSTNAME}${OPENSIM_ESTATE_NAME}${OPENSIM_ESTATE_OWNER_FIRST}${OPENSIM_ESTATE_OWNER_LAST}${OPENSIM_ESTATE_OWNER_PASSWORD}${OPENSIM_ESTATE_OWNER_EMAIL}${OPENSIM_ESTATE_OWNER_UUID}${OPENSIM_CONSOLE_MODE}${OPENSIM_CONSOLE_USER}${OPENSIM_CONSOLE_PASS}${MARIADB_HOST}${MARIADB_DATABASE}${MARIADB_USER}${MARIADB_PASSWORD}${OPENSIM_GRID_NAME}${OPENSIM_GRID_NICK}${OPENSIM_WELCOME_MESSAGE}${OPENSIM_REGION_NAME_SAFE}${OPENSIM_WEBRTC_VOICE_ENABLED}${OPENSIM_JANUS_PUBLIC_HOST}${JANUS_HTTP_PORT}${JANUS_HTTP_BASEPATH}${JANUS_HTTP_ADMIN_PORT}${JANUS_HTTP_ADMIN_BASEPATH}${JANUS_API_TOKEN}${JANUS_ADMIN_TOKEN}' \
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

if [ -f "${TEMPLATES_DIR}/config-include/os-webrtc-janus.ini" ]; then
    printf '[init] Refreshing managed os-webrtc-janus.ini from template.\n'
    envsubst '${OPENSIM_HOSTNAME}${OPENSIM_WEBRTC_VOICE_ENABLED}${OPENSIM_JANUS_PUBLIC_HOST}${JANUS_HTTP_PORT}${JANUS_HTTP_BASEPATH}${JANUS_HTTP_ADMIN_PORT}${JANUS_HTTP_ADMIN_BASEPATH}${JANUS_API_TOKEN}${JANUS_ADMIN_TOKEN}' \
        < "${TEMPLATES_DIR}/config-include/os-webrtc-janus.ini" > "${CONFIG_DIR}/config-include/os-webrtc-janus.ini"
fi

# Ensure existing persisted configs include the WebRTC voice settings file.
if [ -f "${CONFIG_DIR}/config-include/StandaloneCommon.ini" ] && [ -f "${CONFIG_DIR}/config-include/os-webrtc-janus.ini" ]; then
    if ! grep -Eq '^[[:space:]]*Include-WebRtcVoice[[:space:]]*=' "${CONFIG_DIR}/config-include/StandaloneCommon.ini"; then
        printf '[init] Adding Include-WebRtcVoice to StandaloneCommon.ini.\n'
        {
            printf '\n[Modules]\n'
            printf '    Include-WebRtcVoice = "config-include/os-webrtc-janus.ini"\n'
        } >> "${CONFIG_DIR}/config-include/StandaloneCommon.ini"
    fi
fi

should_bootstrap_region_oar="false"
region_count="0"
regionsettings_table_exists="$(mariadb -N -B \
    -h "${MARIADB_HOST}" \
    -u "${MARIADB_USER}" \
    "--password=${MARIADB_PASSWORD}" \
    -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${MARIADB_DATABASE}' AND LOWER(table_name)='regionsettings';")"

if [ "${regionsettings_table_exists}" -gt 0 ]; then
    region_count="$(mariadb -N -B \
        -h "${MARIADB_HOST}" \
        -u "${MARIADB_USER}" \
        "--password=${MARIADB_PASSWORD}" \
        "${MARIADB_DATABASE}" \
        -e "SELECT COUNT(*) FROM regionsettings;")"
    if [ "${region_count}" -eq 0 ]; then
        should_bootstrap_region_oar="true"
    fi
else
    # Schema is not initialized yet; allow bootstrap command generation.
    should_bootstrap_region_oar="true"
fi

if [ "${should_bootstrap_region_oar}" = "true" ]; then
    printf '[init] No existing regions detected (db rows=%s); bootstrap import is enabled.\n' \
        "${region_count:-0}"
else
    printf '[init] Existing region data detected (db rows=%s); bootstrap import is disabled.\n' \
        "${region_count:-0}"
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

if [ "$(printf '%s' "${OPENSIM_CREATE_BOT_USER}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then
    should_add_bot_create_command="false"
    bot_user_exists="unknown"

    user_accounts_table_exists="$(mariadb -N -B \
        -h "${MARIADB_HOST}" \
        -u "${MARIADB_USER}" \
        "--password=${MARIADB_PASSWORD}" \
        -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${MARIADB_DATABASE}' AND LOWER(table_name)='useraccounts';" \
        2>/dev/null || printf '0')"

    if [ "${user_accounts_table_exists}" -gt 0 ]; then
        first_name_sql="$(sql_escape "${OPENSIM_LOGIN_FIRSTNAME}")"
        last_name_sql="$(sql_escape "${OPENSIM_LOGIN_LASTNAME}")"
        existing_bot_user_count="$(mariadb -N -B \
            -h "${MARIADB_HOST}" \
            -u "${MARIADB_USER}" \
            "--password=${MARIADB_PASSWORD}" \
            "${MARIADB_DATABASE}" \
            -e "SELECT COUNT(*) FROM UserAccounts WHERE FirstName='${first_name_sql}' AND LastName='${last_name_sql}';" \
            2>/dev/null || printf '0')"

        if [ "${existing_bot_user_count}" -gt 0 ]; then
            bot_user_exists="true"
        else
            bot_user_exists="false"
        fi

        if [ "${existing_bot_user_count}" -eq 0 ]; then
            should_add_bot_create_command="true"
        fi
    else
        # During first-time init before schema creation, always add the create-user command.
        # Region OAR bootstrap state can be false even on fresh installs once template region ini files exist.
        should_add_bot_create_command="true"

        # Schema not initialized yet: treat user as not yet existing for bootstrap planning.
        bot_user_exists="false"
    fi

    if [ "${should_add_bot_create_command}" = "true" ]; then
        if [ -z "${OPENSIM_LOGIN_UUID}" ]; then
            if [ -r /proc/sys/kernel/random/uuid ]; then
                OPENSIM_LOGIN_UUID="$(cat /proc/sys/kernel/random/uuid)"
            else
                OPENSIM_LOGIN_UUID="$(uuidgen | tr '[:upper:]' '[:lower:]')"
            fi
        fi

        {
            printf '\n# opensim-ai-docker bot bootstrap begin\n'
            printf 'create user "%s" "%s" "%s" "%s" "%s" "%s"\n' \
                "${OPENSIM_LOGIN_FIRSTNAME}" "${OPENSIM_LOGIN_LASTNAME}" \
                "${OPENSIM_LOGIN_PASSWORD}" "${OPENSIM_LOGIN_EMAIL}" \
                "${OPENSIM_LOGIN_UUID}" "${OPENSIM_LOGIN_MODEL}"
            printf '# opensim-ai-docker bot bootstrap end\n'
        } >> "${BOT_STARTUP_FILE}"
        printf '[init] Added startup command to create bot user %s %s.\n' "${OPENSIM_LOGIN_FIRSTNAME}" "${OPENSIM_LOGIN_LASTNAME}"
    else
        printf '[init] Bot user already present (or bootstrap not needed); skipping create-user startup command.\n'
    fi
else
    bot_user_exists="unknown"
fi

if [ "${should_bootstrap_region_oar}" = "true" ]; then
    if [ -f "${DEFAULT_OAR_FILE}" ]; then
        {
            printf '# opensim-ai-docker region bootstrap begin\n'
            printf 'create region "%s" %s %s\n' "${OPENSIM_REGION_NAME}" "${OPENSIM_REGION_X}" "${OPENSIM_REGION_Y}"
            if [ -f "${DEFAULT_OAR_FILE}" ]; then
                printf 'load oar "%s"\n' "${DEFAULT_OAR_FILE}"
            fi
            printf '# opensim-ai-docker region bootstrap end\n'
        } > "${REGION_STARTUP_FILE}"
        printf '[init] Added startup command to import default region OAR %s.\n' "${DEFAULT_OAR_FILE}"
    else
        {
            printf '# opensim-ai-docker region bootstrap begin\n'
            printf 'create region "%s" %s %s\n' "${OPENSIM_REGION_NAME}" "${OPENSIM_REGION_X}" "${OPENSIM_REGION_Y}"
            printf '# opensim-ai-docker region bootstrap end\n'
        } > "${REGION_STARTUP_FILE}"
        printf '[init] WARNING: Default OAR file not found at %s; injecting create-region command only.\n' "${DEFAULT_OAR_FILE}" >&2
    fi
else
    rm -f "${REGION_STARTUP_FILE}"
    printf '[init] Existing region rows detected; skipping automatic OAR import.\n'
fi

# IAR import should depend on whether the target user exists BEFORE startup commands are built.
should_bootstrap_inventory_iar="false"
if [ "$(printf '%s' "${OPENSIM_CREATE_BOT_USER}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then
    if [ "${bot_user_exists:-unknown}" = "false" ]; then
        should_bootstrap_inventory_iar="true"
    fi
fi

if [ "${should_bootstrap_inventory_iar}" = "true" ]; then
    if [ -f "${DEFAULT_IAR_FILE}" ]; then
        {
            printf '# opensim-ai-docker inventory bootstrap begin\n'
            printf 'load iar "%s" "%s" "/" "%s" "%s"\n' \
                "${OPENSIM_LOGIN_FIRSTNAME}" "${OPENSIM_LOGIN_LASTNAME}" \
                "${OPENSIM_LOGIN_PASSWORD}" "${DEFAULT_IAR_FILE}"
            printf '# opensim-ai-docker inventory bootstrap end\n'
        } > "${INVENTORY_STARTUP_FILE}"
        printf '[init] Added startup command to import default IAR %s for %s %s.\n' \
            "${DEFAULT_IAR_FILE}" "${OPENSIM_LOGIN_FIRSTNAME}" "${OPENSIM_LOGIN_LASTNAME}"
    else
        rm -f "${INVENTORY_STARTUP_FILE}"
        printf '[init] WARNING: Default IAR file not found at %s; skipping automatic IAR import.\n' "${DEFAULT_IAR_FILE}" >&2
    fi
else
    rm -f "${INVENTORY_STARTUP_FILE}"
    printf '[init] Target user already exists (or bot-user bootstrap disabled); skipping automatic IAR import.\n'
fi
  
 rm -f "${MERGED_STARTUP_FILE}"
 touch "${MERGED_STARTUP_FILE}"
 if [ -f "${BOT_STARTUP_FILE}" ]; then
     cat "${BOT_STARTUP_FILE}" >> "${MERGED_STARTUP_FILE}"
 fi
 if [ -f "${REGION_STARTUP_FILE}" ]; then
     cat "${REGION_STARTUP_FILE}" >> "${MERGED_STARTUP_FILE}"
 fi
 if [ -f "${INVENTORY_STARTUP_FILE}" ]; then
     cat "${INVENTORY_STARTUP_FILE}" >> "${MERGED_STARTUP_FILE}"
 fi
 if [ -f "${LOCAL_STARTUP_FILE}" ]; then
     cat "${LOCAL_STARTUP_FILE}" >> "${MERGED_STARTUP_FILE}"
 fi

printf '[init] Standalone config generation complete.\n'