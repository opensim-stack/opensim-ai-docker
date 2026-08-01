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

exec docker compose \
  -f docker-compose.release.yml \
  -f docker-compose.release.local.yml \
  up --build "$@"
