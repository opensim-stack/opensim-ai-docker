#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$ROOT_DIR"

while [ "$#" -gt 0 ]; do
    case "$1" in
        --local)
            export OPENSIM_TAG=local
            export OPENSIM_GROUP=_
            export OPENSIM_SPAWNER_IMAGE=opensim-spawner:local
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

if [ -z "${OPENSIM_HOSTNAME}" ]; then
    echo "OPENSIM_HOSTNAME is no. Please set it before running or add hostname as argument."
    exit 1
fi

docker network create opensim-ai && docker run -it \
  --restart unless-stopped \
  --pull missing \
  --name opensim-ai-spawner \
  --network opensim-ai \
  -v opensim-ai_opensim-config:/config \
  -v opensim-ai_opensim-workspace:/workspace \
  -v opensim-ai_opensim-spawner-data:/data \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 8993:8993/tcp \
  -e OPENSIM_HOSTNAME="${OPENSIM_HOSTNAME}" \
  ${OPENSIM_SPAWNER_IMAGE:-${OPENSIM_GROUP:-bithatch/}opensim-spawner:${OPENSIM_TAG:-latest}}
