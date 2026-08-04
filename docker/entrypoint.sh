#!/bin/sh
set -eu

CONFIG_DIR="${CONFIG_DIR:-/workspace}"
BIN_DIR="/opt/opensim/bin"

printf '[opensim] Installing config files from %s ...\n' "${CONFIG_DIR}"

if [ -f "${CONFIG_DIR}/OpenSim.ini" ]; then
    cp -f "${CONFIG_DIR}/OpenSim.ini" "${BIN_DIR}/OpenSim.ini"
fi

if [ -f "${CONFIG_DIR}/config-include/StandaloneCommon.ini" ]; then
    mkdir -p "${BIN_DIR}/config-include"
    cp -f "${CONFIG_DIR}/config-include/StandaloneCommon.ini" "${BIN_DIR}/config-include/StandaloneCommon.ini"
fi

if [ ! -f "${BIN_DIR}/Regions/Region.ini" ] && [ -f "${CONFIG_DIR}/Regions/Region.ini" ]; then
    mkdir -p "${BIN_DIR}/Regions"
    cp -f "${CONFIG_DIR}/Regions/Region.ini" "${BIN_DIR}/Regions/Region.ini"
fi

if [ -f "${CONFIG_DIR}/startup_commands.txt" ]; then
    cp -f "${CONFIG_DIR}/startup_commands.txt" "${BIN_DIR}/startup_commands.txt"
fi

if [ -f "${CONFIG_DIR}/shutdown_commands.txt" ]; then
    cp -f "${CONFIG_DIR}/shutdown_commands.txt" "${BIN_DIR}/shutdown_commands.txt"
fi

if [ ! -f "${BIN_DIR}/config-include/FlotsamCache.ini" ] && [ -f "${BIN_DIR}/config-include/FlotsamCache.ini.example" ]; then
    cp "${BIN_DIR}/config-include/FlotsamCache.ini.example" "${BIN_DIR}/config-include/FlotsamCache.ini"
    printf '[opensim] Created FlotsamCache.ini from example.\n'
fi

touch "${BIN_DIR}/startup_commands.txt"
touch "${BIN_DIR}/shutdown_commands.txt"

console_mode="$(awk -F= '
    /^[[:space:]]*console[[:space:]]*=/{
        value=$2
        gsub(/[[:space:]"]/, "", value)
        print tolower(value)
        exit
    }
' "${BIN_DIR}/OpenSim.ini" 2>/dev/null || true)"

# Allow explicit override; otherwise auto-select based on console mode.
OPENSIM_BACKGROUND="${OPENSIM_BACKGROUND:-auto}"
if [ "${OPENSIM_BACKGROUND}" = "auto" ]; then
    if [ "${console_mode}" = "rest" ]; then
        OPENSIM_BACKGROUND="false"
    else
        OPENSIM_BACKGROUND="true"
    fi
fi

cd "${BIN_DIR}"
ulimit -s 1048576

if [ "${OPENSIM_BACKGROUND}" = "true" ]; then
    printf '[opensim] Starting OpenSimulator in background mode...\n'
    exec dotnet OpenSim.dll -background=true
fi

printf '[opensim] Starting OpenSimulator in foreground mode...\n'
exec dotnet OpenSim.dll
