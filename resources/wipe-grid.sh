#!/bin/bash

echo "********************************************************************"
echo "WARNING: This script will wipe all containers data in the local grid."
echo
echo "Containers, Volumes and Networks with the prefix '${COMPOSE_PROJECT_NAME:-opensim-ai}' will be removed." 
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

# Spawned containers
set x $(docker container ls -a|awk '{ print $NF }'|grep -v NAMES) ; shift
if [ "$#" -gt 0 ]; then
    for i in $@; do
        case "$i" in
            ${COMPOSE_PROJECT_NAME:-opensim-ai}-*)
                  echo "Removing containers: $i"
                  docker container stop -t 10 "$i"
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
            ${COMPOSE_PROJECT_NAME:-opensim-ai}_*)
                echo "Removing volume: $i"
                docker volume rm -f "$i"
                ;;
            *) ;;
        esac
    done
fi

# Networks
set x $(docker network ls|awk '{ print $2 }'|grep -v NAME) ; shift
if [ "$#" -gt 0 ]; then
    for i in $@; do
        case "$i" in
            ${COMPOSE_PROJECT_NAME:-opensim-ai}*)
                echo "Removing network: $i"
                docker network rm -f "$i"
                ;;
            *) ;;
        esac
    done
fi