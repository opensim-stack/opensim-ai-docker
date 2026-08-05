#!/bin/sh
set -eu

WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
OPENSIM_DIR="${OPENSIM_DIR:-/opt/opensim}"
TEMPLATES_DIR="${TEMPLATES_DIR:-${OPENSIM_DIR}/docker/templates}"
BIN_DIR="${BIN_DIR:-${OPENSIM_DIR}/bin}"

mkdir -p "${WORKSPACE_DIR}"

printf '[opensim] Installing config files from %s ...\n' "${TEMPLATES_DIR}"

if [ -f "${TEMPLATES_DIR}/OpenSim.ini" ]; then
    cp -f "${TEMPLATES_DIR}/OpenSim.ini" "${BIN_DIR}/OpenSim.ini"
fi

if [ -f "${TEMPLATES_DIR}/config-include/StandaloneCommon.ini" ]; then
    mkdir -p "${BIN_DIR}/config-include"
    cp -f "${TEMPLATES_DIR}/config-include/StandaloneCommon.ini" "${BIN_DIR}/config-include/StandaloneCommon.ini"
fi

if [ ! -f "${BIN_DIR}/Regions/Region.ini" ] && [ -f "${TEMPLATES_DIR}/Regions/Region.ini" ]; then
    mkdir -p "${BIN_DIR}/Regions"
    cp -f "${TEMPLATES_DIR}/Regions/Region.ini" "${BIN_DIR}/Regions/Region.ini"
fi

if [ -f "${TEMPLATES_DIR}/startup_commands.txt" ]; then
    cp -f "${TEMPLATES_DIR}/startup_commands.txt" "${BIN_DIR}/startup_commands.txt"
fi

if [ -f "${TEMPLATES_DIR}/shutdown_commands.txt" ]; then
    cp -f "${TEMPLATES_DIR}/shutdown_commands.txt" "${BIN_DIR}/shutdown_commands.txt"
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
