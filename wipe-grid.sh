#!/bin/bash

echo "********************************************************************"
echo "WARNING: This script will wipe all containers data in the local grid."
echo "********************************************************************"
echo "Are you sure you want to continue? (y/n)"
read -r answer
case "${answer}" in
  y|Y)
    echo "Wiping all containers data in the local grid..."
    ;;
  n|N)
    echo "Aborting."
    exit 0
    ;;
  *)
    echo "Invalid input. Aborting."
    exit 1
    ;;
esac

cd "$(dirname "$0")" || exit 1
docker compose down -v --remove-orphans

# Spawned containers
set x $(docker container ls -a|awk '{ print $NF }'|grep -v NAMES) ; shift
if [ "$#" -gt 0 ]; then
    for i in $@; do
        case "$i" in
            opensim-ai-*)
                  echo "Removing containers: $i"
                  docker container rm -f "$i"
                ;;
            *) ;;
        esac
    done
fi
docker container prune -f

# Volumes
set x $(docker volume ls -q) ; shift
if [ "$#" -gt 0 ]; then
    for i in $@; do
        case "$i" in
            opencode-data|opencode-cache|opencode-config|opencode-state-*|opencode-tool-*|opensim-ai*|opensim-workspace*|piper-voices)
                echo "Removing volume: $i"
                docker volume rm -f "$i"
                ;;
            *) ;;
        esac
    done
fi