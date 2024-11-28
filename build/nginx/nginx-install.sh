#!/bin/bash

# ------------------------------ #
# Key Objectives for this script #
# ------------------------------ #

# 1. Update system
# 2. Have user edit the `.env.example` to set environment variables
# 3. cp `.env.example` to `.env`
# 4. Run NGNIX `build/nginx/docker-compose.yml` file to pull docker containers
# 5. cp `nginx.conf` to its necessary place
# 6. Install Zerotier (check `.env` for zerotier conf. if none are set, prompt user for Zerotier Network ID, then join them to that network)
# 7. Start all containers, and ensure volumes are attached and connected
# 8. Print out in the terminal the URL where the user can go to access NGINX to continue the setup process

# Function to update the system
update_system() {
    echo "Updating system..."
    sudo apt-get update && sudo apt-get upgrade -y
}

# Function to prompt user to edit .env.example
edit_env_file() {
    echo "Please edit the .env.example file to set your environment variables."
    read -p "Press enter to continue after editing..."
    cp .env.example .env
}

# Function to run Docker Compose
run_docker_compose() {
    echo "Running Docker Compose to pull containers..."
    docker-compose -f build/nginx/docker-compose.yml pull
}

# Function to copy nginx.conf
copy_nginx_conf() {
    echo "Copying nginx.conf to the necessary location..."
    cp build/nginx/nginx.conf /etc/nginx/nginx.conf
}

# Function to install Zerotier and join network
install_zerotier() {
    echo "Installing Zerotier..."
    curl -s https://install.zerotier.com | sudo bash

    # Check if Zerotier Network ID is set
    source .env
    if [ -z "$ZEROTIER_NETWORK_ID" ] || [ "$ZEROTIER_NETWORK_ID" == "ZEROTIER_NETWORK_ID" ]; then
        read -p "Enter your Zerotier Network ID: " ZEROTIER_NETWORK_ID
        echo "ZEROTIER_NETWORK_ID=$ZEROTIER_NETWORK_ID" >> .env
    fi

    sudo zerotier-cli join $ZEROTIER_NETWORK_ID
}

# Function to start Docker containers
start_containers() {
    echo "Starting Docker containers..."
    docker-compose -f docker-compose.yml up -d
}

# Function to print access URL
print_access_url() {
    echo "Setup complete. You can access your NGINX server at http://${DOMAIN}"
}

# Main script execution
update_system
edit_env_file
run_docker_compose
copy_nginx_conf
install_zerotier
start_containers
print_access_url