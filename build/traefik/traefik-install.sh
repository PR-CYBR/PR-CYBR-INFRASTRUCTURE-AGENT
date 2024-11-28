#!/bin/bash

# ------ #
# TODO #
# - [ ] apply logic to have it open new shell / subshell
# - [ ] check system for docker installation / version (if none found, install docker and dependaceies)
# ------ #

echo "Building and starting Traefik service..."
docker-compose up --build -d
echo "Traefik service is up and running." 