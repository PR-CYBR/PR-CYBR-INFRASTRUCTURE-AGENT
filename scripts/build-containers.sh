#!/bin/bash

# ------------------------------- #
# Key Objectives for this script: #
#
# 1. Update system
# 2. Used by other automations as a self-healing script that will help resolve conflicts by:
#   - building new container of enviornment
#   - updating existing Dockerfile
#   - updating existing docker-compose.yml file
#   - updating existing `.env` file with necessary enviornment variables
#   - updating existing package.json (if necessary)
#   - runs docker-compose down && docker-compose build 
#   - runs docker-compose up
#   - runs docker ps
# 3. Prints success message once all containers have been updated and have sucessfully been rebuilt and deployed
