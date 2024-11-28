#!/bin/bash

echo "Building and starting Traefik service..."
docker-compose up --build -d
echo "Traefik service is up and running." 