#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$ROOT_DIR"

if [ ! -f .env ]; then
    echo "No .env file found. Creating from .env.example ..."
    cp .env.example .env
    echo "Created .env. Review it before re-running if needed."
fi

missing=0
for var in OSGRID_REGION_NAME OSGRID_REGION_UUID OSGRID_REGION_LOCATION OSGRID_EXTERNAL_HOSTNAME; do
    value="$(awk -F= -v k="$var" '$1==k {print substr($0, index($0,$2))}' .env | tail -n1)"
    if [ -z "$value" ]; then
        echo "Missing required variable in .env: $var"
        missing=1
    fi
done

if [ "$missing" -ne 0 ]; then
    echo "Set the required OSGRID_* values in .env, then run again."
    exit 1
fi

export OPENSIM_OSGRID_IMAGE="${OPENSIM_OSGRID_IMAGE:-opensim-ai-osgrid:latest}"

exec docker compose \
  -f docker-compose.osgrid.yml \
  -f docker-compose.osgrid.local.yml \
  up --build "$@"
