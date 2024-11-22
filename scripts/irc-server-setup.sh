#!/bin/bash

# ------------------------------ #
# Key Objectives for this Script #
#                                # 
# 1. Update system               # 
# 2. Create a script Index (stages the script goes through) 
# 3. Use 2 Banners to mark each section of script (1 for the section name, 1 for the Section Breakdown)
# 4. Under each banner, put the following: 
#     - Section Breakdown
#        - Purpose: explaining this section's purpose
#        - Explanation of section in depth
#        - Explanation of this section in relation to the whole script
#        - Explain what Stage of the script this section is
#        - Improvements that could be made to this section
#        - Highlight important info (such as variables)
#        - Troubleshooting tips for this section
# 5. Create a log file for this script (named after the script)
# 6. Create the following subshell's:
#     - analyzer: a shell used for analyzing system
#     - logger: a shell used for tailing output of this script into logfile (for troubleshooting / debugging)
#     - config: a shell used for updating system files
#     - installer: a shell used for updating and installing packages, dependencies, libraries, or software
# 7. Create an initialization and cleanup script for each subshell (and have the script run the initialization script when the subshell starts for the first time, and run the cleanup script prior to killing the subshell)
# 8. Structure script to delegate out tasks to their respective subshell, the subshells are the following:
#     - analyzer
#     - logger
#     - config
#     - installer
# 9. Create a "Loading Room" (name it something relative to the script) type experience for the user when running the script, where the user gets loaded into a shell that displays the setup's current status and progress
# 10. Have a loading bar implemented in the Loading Room to display to the user to allow them to track the status and at what stage the script is currently in (and have the)
# 11. If the script is meant to be multi-purpose, create a menu list of options to display to the user in the Loading Room

# Log file
LOGFILE="/var/log/irc-server-setup.log"
exec > >(tee -i "$LOGFILE")
exec 2>&1

# Function to log messages with timestamps
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

log_message "Starting IRC Server Setup..."

# Function to simulate a loading bar
loading_bar() {
    echo -n "Progress: ["
    for ((i=0; i<50; i++)); do
        echo -n "#"
        sleep 0.1
    done
    echo "]"
}

# ------------------------------ #
# Stage 1: System Update         #
# ------------------------------ #
# Section Breakdown
# Purpose: Ensure the system is up-to-date with the latest packages and security patches.
# Explanation: This section updates the package list and upgrades all installed packages.
# Relation to Script: This is the first step, ensuring a stable base for further installations.
# Stage: 1
# Improvements: Add more package management options for different distributions.
# Important Info: Uses `apt` for package management.
# Troubleshooting: Ensure you have internet connectivity and correct permissions.

log_message "Updating the system..."
loading_bar
sudo apt update && sudo apt upgrade -y

# ------------------------------ #
# Stage 2: Docker Installation   #
# ------------------------------ #
# Section Breakdown
# Purpose: Install Docker to run the Inspircd IRC server in a container.
# Explanation: Checks if Docker is installed, and installs it if not.
# Relation to Script: Essential for running the IRC server in a containerized environment.
# Stage: 2
# Improvements: Check for Docker Compose installation as well.
# Important Info: Docker service is started and enabled.
# Troubleshooting: Verify Docker installation with `docker --version`.

log_message "Checking Docker installation..."
loading_bar
if ! command -v docker &> /dev/null; then
    log_message "Docker not found, installing..."
    sudo apt install docker.io -y
    sudo systemctl start docker
    sudo systemctl enable docker
else
    log_message "Docker is already installed."
fi

# ------------------------------ #
# Stage 3: Zerotier Setup        #
# ------------------------------ #
# Section Breakdown
# Purpose: Install and configure Zerotier for secure network connections.
# Explanation: Installs Zerotier, joins a network, and configures Docker to use it.
# Relation to Script: Allows secure, private network connections for the IRC server.
# Stage: 3
# Improvements: Automate network authorization.
# Important Info: Requires a Zerotier network ID.
# Troubleshooting: Ensure Zerotier service is running and network ID is correct.

log_message "Installing Zerotier..."
loading_bar
curl -s https://install.zerotier.com | sudo bash

read -p "Enter Zerotier Network ID: " ZT_NETWORK_ID
log_message "Joining Zerotier network ${ZT_NETWORK_ID}..."
sudo zerotier-cli join $ZT_NETWORK_ID

# Wait for Zerotier to join the network
sleep 10

# Get Zerotier IP address
ZT_IP_ADDRESS=$(sudo zerotier-cli listnetworks | grep $ZT_NETWORK_ID | awk '{print $NF}')
log_message "Zerotier IP Address: $ZT_IP_ADDRESS"

# ------------------------------ #
# Stage 4: Inspircd Setup        #
# ------------------------------ #
# Section Breakdown
# Purpose: Set up the Inspircd IRC server using Docker.
# Explanation: Pulls the Inspircd image and runs it with specified configurations.
# Relation to Script: Core functionality to provide IRC services.
# Stage: 4
# Improvements: Allow more configuration options for Inspircd.
# Important Info: Uses Docker environment variables for configuration.
# Troubleshooting: Check Docker logs with `docker logs inspircd`.

log_message "Installing Inspircd using Docker..."
loading_bar
sudo docker pull inspircd/inspircd

# Prompt for user details
read -p "Enter the server name: " SERVER_NAME

log_message "Starting Inspircd container..."
sudo docker run -d \
    --name inspircd \
    -e "SERVER_NAME=${SERVER_NAME}" \
    -e "IP_ADDRESS=${ZT_IP_ADDRESS}" \
    -p 6667:6667 \
    inspircd/inspircd

# ------------------------------ #
# Stage 5: Nginx Setup (Docker)  #
# ------------------------------ #
# Section Breakdown
# Purpose: Install and configure Nginx as a reverse proxy using Docker.
# Explanation: Sets up Nginx in a Docker container to forward requests to the IRC server.
# Relation to Script: Provides a web interface for IRC access.
# Stage: 5
# Improvements: Add SSL configuration for secure connections.
# Important Info: Configures Nginx to listen on port 80.
# Troubleshooting: Check Docker logs with `docker logs nginx`.

log_message "Setting up Nginx as a reverse proxy in Docker..."
loading_bar
sudo docker run -d \
    --name nginx \
    -p 80:80 \
    -v /etc/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
    nginx

# Create a custom Nginx configuration for the reverse proxy
cat <<EOL | sudo tee /etc/nginx/nginx.conf
events {}
http {
    server {
        listen 80;
        server_name ${SERVER_NAME};

        location / {
            proxy_pass http://${ZT_IP_ADDRESS}:6667;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOL

# Reload Nginx configuration
sudo docker exec nginx nginx -s reload

log_message "IRC Server Setup Completed Successfully!"

# Additional logging and cleanup can be added as needed