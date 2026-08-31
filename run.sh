#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$ROOT_DIR"

if [ ! -f .env ]; then
    echo "No .env file found. Creating from .env.example ..."
    cp .env.example .env
    echo "Created .env. Review it before re-running if needed."
fi

if [ $(grep -c '^OPENSIM_HOSTNAME=' .env) -eq 0 ]; then
    echo "OPENSIM_HOSTNAME is not set in .env. Please set it before running."
    exit 1
fi

export OPENSIM_RELEASE_IMAGE="${OPENSIM_RELEASE_IMAGE:-opensim-ai-standalone:latest}"

while [ "$#" -gt 0 ]; do
    case "$1" in
        --local)
            export OPENSIM_OPENCODE_IMAGE=opensim-opencode:local
            export OPENSIM_PIPER_IMAGE=opensim-piper:local
            export OPENSIM_BLENDER_IMAGE=opensim-blender:local
            export OPENSIM_METAVERSE2MCP_IMAGE=opensim-metaverse2mcp:local
            export OPENSIM_SPAWNER_IMAGE=opensim-spawner:local
            export OPENSIM_CONSOLE2MCP_IMAGE=opensim-console2mcp:local
            export OPENSIM_SIMULATOR_IMAGE=opensim-simulator:local
            export OPENSIM_DATABASE2MCP_IMAGE=opensim-database2mcp:local
            ;;
        --*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)  if [ -z "${OPENSIM_HOSTNAME:-}" ]; then
                export OPENSIM_HOSTNAME="$1"
            else
                echo "Unknown option: $1"
                exit 1
            fi
            ;;
    esac
    shift
done

exec docker compose \
  -f docker-compose.yml \
  -f docker-compose.local.yml \
  up --build "$@"
