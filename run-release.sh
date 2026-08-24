#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$ROOT_DIR"

if [ ! -f .env ]; then
    echo "No .env file found. Creating from .env.example ..."
    cp .env.example .env
    echo "Created .env. Review it before re-running if needed."
fi

export OPENSIM_RELEASE_IMAGE="${OPENSIM_RELEASE_IMAGE:-opensim-ai-standalone:latest}"

if [ "${1:-}" = "--local" ] ; then
    shift
    export OPENSIM_OPENCODE_IMAGE=opensim-opencode:local
    export OPENSIM_PIPER_IMAGE=opensim-piper:local
    export OPENSIM_BLENDER_IMAGE=opensim-blender:local
    export OPENSIM_METAVERSE2MCP_IMAGE=opensim-metaverse2mcp:local
    export OPENSIM_SPAWNER_IMAGE=opensim-spawner:local
    export OPENSIM_CONSOLE2MCP_IMAGE=opensim-console2mcp:local
    export OPENSIM_SIMULATOR_IMAGE=opensim-simulator:local
fi

exec docker compose \
  -f docker-compose.release.yml \
  -f docker-compose.release.local.yml \
  up --build "$@"
