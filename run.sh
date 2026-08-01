#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$ROOT_DIR"

if [ ! -f .env ]; then
    echo "No .env file found. Creating from .env.example ..."
    cp .env.example .env
    echo "Created .env. Review it before re-running if needed."
fi

export OPENSIM_SOURCE_IMAGE="${OPENSIM_SOURCE_IMAGE:-opensim-ai-standalone:dev}"

exec docker compose \
  -f docker-compose.yml \
  -f docker-compose.local.yml \
  up --build "$@"
