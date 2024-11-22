#!/bin/bash

# --------------------------------------------- #
# Key Objectives for the System Debugger Script #
# 
# 1. Update system (and install tmux, git, and curl)
# 2. Creates new shell called `sys-debugger`
# 3. Creates an initialization file for `sys-debug`
# 4. Creates a cleanup file for `sys-debugger`
# 5. Creates a `.sys_env` file for `sys-debug` shell (and sets it in it's PATH)
#   - Sections:
#       - `## System Commands / Aliases / Variables`
#       - `## Network Commands / Aliases / Variables`
#       - `## Git Commands / Aliases / Variables`
#       - `## Docker Commands / Aliases / Variables`
#       - `## TMUX Commands / Aliases / Variables`
#       - `## Zerotier Commands / Aliases / Variables`
# 
# 6. Creates a directory for `sys-debugger` shell (and sets it as it's home directory)
# 7. Starts `sys-debugger` shell (and sources it's `.sys_env` file to export it's variables)
# 8. Once it's loaded the new shell, have it present the user with an ASCII Art Banner saying "Sys-Debugger Menu", listing the following options:
#       1. Status Check of the System (`syschk``)
#       2. Fix Missing or Broken Packages (`fix-broken`)
#       3. Security Audit (`audit`)
#       4. Fix Configuration Settings (`fix-config`)
#       5. Preform a Backup (`backup`)
# 
# 9. Once the user inputs their choice, create a sub / child shell called it's associate option name (the short version) an loads the userinto that shell
# 10. User Option Routes:
#       1. Status Check of the System (`syschk`)
#           - loads user into new shell called `syschk`
#           - sources `.sys_env`
#           - creates file called `syschk-sys-debugger.log`
#           - uses `cat` to output (`>`) the following files and their contents into `syschk-sys-debugger.log`:
#               - `/var/log/apache2/*` (access and error logs for the apache web server)
#               - `/var/log/auth.log` (information on user logins, priviliaged access, and remote authentication)
#               - `/var/log/kern.log` (kernel logs)
#               - `/var/log/messages` (general non-critical system information)
#               - `/var/log/syslog` (general system logs)
#           - cat output of systemctl status --verbose into `syschk-sys-debugger.log`
#           - cat output of looking up current users on system into `syschk-sys-debugger.log`
#           - cat out put of ps -aux into `syschk-sys-debugger.log`
#           - find issues related to systemctl (or system level equivent process) (and output the to the `syschk-sys-debugger.log` file)
#           - if there are issues found, be verbose in printing the message explaing as to what issue was found, and why it is an issue
#           - offer suggestions as to solutions for these issues
#           - if it can remidiate the issue, prompt the user asking if they would like for you to proceed with remidaiation of said issue
#               - If Yes:
#                  - attempt to resolve the issue 3 times
#               - If no:
#                  - cat remediation steps into `syschk-sys-debugger.log` file
#           - find any kernel level issues (such as drivers. etc.)
#               - if there are kernel level issues found, be verbose in printing the message explaining what issue was found, and why it is an issue
#               - offer suggestions as to solutions for these issues
#               - if it can remidiate the issue, prompt the user asking if they would like for you to proceed with remidaiation of said issue
#                   - If Yes:
#                       - attempt to resolve the issue 3 times
#                   - In no:
#                       - cat remediation steps into `syschk-sys-debugger.log` file
#           - cat shell history into `syschk-sys-debugger.log` file (to ensure documenting of commands ran by the shell) 
#           - runs cleanup script to remove the files it created (execept for the `syschk-sys-debugger.log` file), then kills the shell to return to the parent shell
# 
#       2. Fix Missing or Broken Packages (`fix-broken`)
#           - loads user into new shell called `fix-broken`
#           - creates new file called `fix-broken-sys-debugger.log`
#           - sources `.sys_env` file to export enviornment variables
#           - identify the avaliable package managers for the system (and determine default for that user) (echo that into `fix-broken-sys-debugger.log`)
#           - find any current issues with package manager
#           - if issues are found, be verbose in printing the message explaining what issue was found, and why it is an issue
#           - offer suggestions as to solutions for these issues
#           - if it can remidiate the issue, prompt the user asking if they would like for you to proceed with remidaiation of said issue
#               - If Yes:
#                   - attempt to resolve the issue 3 times
#               - If no:
#                       - cat remediation steps into `fix-broken-sys-debugger.log` file
#           - cat shell history into `fix-broken-sys-debugger.log` file (to ensure documenting of commands ran by the shell) 
#           - runs cleanup script to remove the files it created (execept for the `fix-broken-sys-debugger.log` file), then kills the shell to return to the parent shell
#           
#       3. Security Audit (`audit`)
#           - loads user into new shell called `audit`
#           - creates new file called `audit-sys-debugger.log`
#           - sources `.sys_env` file to export enviornment variables
#           - install's Lynis (and preforms system audit) and output's it to the `audit-sys-debugger.log` file
#           - from the system audit, determine what (if any) security vulnerabilities exist on this machine
#           - offer suggestions as to solutions for these issues
#           - if it can remidiate the issue, prompt the user asking if they would like for you to proceed with remidaiation of said issue
#               - If Yes:
#                  - attempt to resolve the issue 3 times
#               - In no:
#                  - cat remediation steps into `audit-sys-debugger.log` file
#           - cat shell history into `audit-sys-debugger.log` file (to ensure documenting of commands ran by the shell) 
#           - runs cleanup script to remove the files it created (execept for the `audit-sys-debugger.log` file), then kills the shell to return to the parent shell
#           
#       4. Fix Configuration Settings (`fix-config`)
#           - loads user into new shell called `fix-config`
#           - creates new file called `fix-config-sys-debugger.log`
#           - sources `.sys_env` file to export enviornment variables
#           - provides summary of current system configurations (common ones)
#           - cat output of systemctl status --verbose command output into `fix-config-sys-debugger.log` file
#           - find issues related to network configuration files
#           - if issues are found, be verbose in printing the message explaining what issue was found, and why it is an issue
#           - offer suggestions as to solutions for these issues
#           - if it can remidiate the issue, prompt the user asking if they would like for you to proceed with remidaiation of said issue
#               - If Yes:
#                  - attempt to resolve the issue 3 times
#               - In no:
#                  - cat remediation steps into `fix-config-sys-debugger.log` file
#           - cat shell history into `fix-config-sys-debugger.log` file (to ensure documenting of commands ran by the shell) 
#           - runs cleanup script to remove the files it created (execept for the `fix-config-sys-debugger.log` file), then kills the shell to return to the parent shell
#           
#       5. Preform a Backup (`backup`)
#           - loads user into new shell called `backup`
#           - creates new file called `backup-sys-debugger.log`
#           - sources `.sys_env` file to export enviornment variables
#           - prompts user to choose from a list of options:
#               - 1. Backup a File
#                     - prompt user for desired transfer type
#                        - FTP
#                           - prompt user for target IP address
#                        - Web-Server
#                           - prompt user to choose from the following options:
#                               - Local (sending)
#                                   - print instructions to user on how to create a new network on Zerotier Central, and have them note down the Zerotier Network ID
#                                   - prompt the user for the Zerotier Network ID
#                                   - setup a basic http-server and use nginx as a reverse tcp proxy (set to only allow connects through zerotier network device)
#                                   - print instructions out to user on where to navigate to to view and download their files
#                               - Remote (retrieving)
#                        - IRC
#                           - prompt user to choose from the following options:
#                               - Local (sending)
#                                   - check if Irssi is installed (if it's not install it)
#                                       - join irc.freenode.net server (`/connect chat.freenode.net`)
#                                       - create new channel
#                               - Remote (retrieving)
#                                   - check if Irssi is installed (if it's not install it)
#                                   - prompt user to enter the following details:
#                                       - Server-Name (the IRC server to connect to)
#                                       - Channel-Name (optional / if known)
#                                       - User-Name (optional / if known)
#                                   - if channel doesn't exist create channel (and if it does, join it)
#                                   - upload files to channel
#                                   - if the user doesn't exist proceed with inputing complete message in created / joined channel
#                        - Local
#                           - prompt the user for desired location to save to (defaults to users home directory)
#               - 2. Backup a Directory
#                     - prompt user for desired transfer type
#                        - FTP
#                           - prompt user for target IP address
#                        - Web-Server
#                           - prompt user to choose from the following options:
#                               - Local (sending)
#                                   - print instructions to user on how to create a new network on Zerotier Central, and have them note down the Zerotier Network ID
#                                   - prompt the user for the Zerotier Network ID
#                                   - setup a basic http-server and use nginx as a reverse tcp proxy (set to only allow connects through zerotier network device)
#                                   - print instructions out to user on where to navigate to to view and download their files
#                               - Remote (retrieving)
#                        - IRC
#                           - prompt user to choose from the following options:
#                               - Local (sending)
#                                   - check if Irssi is installed (if it's not install it)
#                                       - join irc.freenode.net server (`/connect chat.freenode.net`)
#                                       - create new channel
#                               - Remote (retrieving)
#                                   - check if Irssi is installed (if it's not install it)
#                                   - prompt user to enter the following details:
#                                       - Server-Name (the IRC server to connect to)
#                                       - Channel-Name (optional / if known)
#                                       - User-Name (optional / if known)
#                                   - if channel doesn't exist create channel (and if it does, join it)
#                                   - upload files to channel
#                                   - if the user doesn't exist proceed with inputing complete message in created / joined channel
#                        - Local
#                           - prompt the user for desired location to save to (defaults to users home directory)
#               - 3. Archive a File
#                     - prompt user for desired file type:
#                        - zip
#                        - tar
#                     - prompt user for desired location to save it to (defaults to the users home directory)
#               - 4. Archive a Directory
#                     - prompt user for desired file type:
#                        - zip
#                        - tar
#                     - prompt user for desired location to save it to (defaults to the users home directory)
#           - cat shell history into `backup-sys-debugger.log` file (to ensure documenting of commands ran by the shell) 
#           - runs cleanup script to remove the files it created (execept for the `backup-sys-debugger.log` file), then kills the shell to return to the parent shell
# 11. Returns to `sys-debugger` shell and run's nano to view the `.log` file (the one named after the option they chose)
# 12. Once the user exits nano, prompt them with the following options:
#      - 1. Get a summary of test results
#            - provide a summary `.log` file (the one named after the option they chose)
#      - 2. Run another test
#            - return user to "Sys-Debugger Menu"
#      - 3. Exit `sys-debugger` program
#            - runs cleanup file, kills `sys-debugger` shell
# 13. Print the following message to the user:
#       - "Thank you for using the Sys-Debugger Script, if you have feedback or issues with the script, open a new issue here: https://github.com/PR-CYBR/PR-CYBR-INFRASTRUCTURE-AGENT/issues"
# 14. End script

# Function to update the system and install necessary packages
update_system() {
    echo "Updating system and installing tmux, git, and curl..."
    
    # Update the package list
    sudo apt update
    
    # Upgrade all installed packages to their latest versions
    sudo apt upgrade -y
    
    # Install tmux, git, and curl
    sudo apt install -y tmux git curl
    
    # Clean up any unnecessary packages
    sudo apt autoremove -y
    
    # Confirm installation
    echo "Installation complete. Verifying installations..."
    for package in tmux git curl; do
        if dpkg -l | grep -q "^ii  $package"; then
            echo "$package is installed."
        else
            echo "Error: $package is not installed."
        fi
    done
}

# Function to create a new shell called `sys-debugger`
create_sys_debugger_shell() {
    echo "Creating sys-debugger shell..."

    # Define the shell script path
    SYS_DEBUGGER_SCRIPT="/usr/local/bin/sys-debugger"

    # Create the shell script
    cat << 'EOF' | sudo tee $SYS_DEBUGGER_SCRIPT > /dev/null
#!/bin/bash
# Sys-Debugger Shell

# Load environment variables
if [ -f ~/.sys_env ]; then
    source ~/.sys_env
fi

# Start a new shell session
bash --rcfile ~/.sys_env
EOF

    # Make the script executable
    sudo chmod +x $SYS_DEBUGGER_SCRIPT

    echo "Sys-debugger shell created at $SYS_DEBUGGER_SCRIPT. You can start it by running 'sys-debugger'."
}

# Function to create an initialization file for `sys-debug`
create_initialization_file() {
    echo "Creating initialization file for sys-debug..."

    # Define the initialization file path
    INIT_FILE="$HOME/.sys_env"

    # Create the initialization file with environment variables and aliases
    cat << 'EOF' > $INIT_FILE
# Sys-Debug Initialization File

# System Commands / Aliases / Variables
alias ll='ls -la'
export EDITOR=nano

# Network Commands / Aliases / Variables
alias myip='curl ifconfig.me'

# Git Commands / Aliases / Variables
alias gst='git status'
alias gpl='git pull'

# Docker Commands / Aliases / Variables
alias dps='docker ps'
alias dcu='docker-compose up'

# TMUX Commands / Aliases / Variables
alias ta='tmux attach'
alias tls='tmux list-sessions'

# Zerotier Commands / Aliases / Variables
alias ztlist='zerotier-cli listnetworks'

# Add more custom commands and environment variables as needed
EOF

    # Notify the user
    echo "Initialization file created at $INIT_FILE."
}

# Function to create a cleanup file for `sys-debugger`
create_cleanup_file() {
    echo "Creating cleanup file for sys-debugger..."

    # Define the cleanup script path
    CLEANUP_SCRIPT="$HOME/sys-debugger-cleanup.sh"

    # Create the cleanup script
    cat << 'EOF' > $CLEANUP_SCRIPT
#!/bin/bash
# Sys-Debugger Cleanup Script

# Remove temporary files
echo "Cleaning up temporary files..."
rm -f ~/syschk-sys-debugger.log
rm -f ~/fix-broken-sys-debugger.log
rm -f ~/audit-sys-debugger.log
rm -f ~/fix-config-sys-debugger.log
rm -f ~/backup-sys-debugger.log

# Kill any lingering processes if necessary
# Example: killall -q some_process_name

# Notify the user
echo "Cleanup complete."
EOF

    # Make the script executable
    chmod +x $CLEANUP_SCRIPT

    # Notify the user
    echo "Cleanup file created at $CLEANUP_SCRIPT."
}

# Function to create a `.sys_env` file and set it in the PATH
create_sys_env_file() {
    echo "Creating .sys_env file..."

    # Define the .sys_env file path
    SYS_ENV_FILE="$HOME/.sys_env"

    # Create the .sys_env file with environment variables and configurations
    cat << 'EOF' > $SYS_ENV_FILE
# Sys-Debugger Environment File

# Add custom environment variables here
export SYS_DEBUGGER_HOME="$HOME/sys-debugger"
export PATH="$SYS_DEBUGGER_HOME/bin:$PATH"

# Example aliases
alias ll='ls -la'
alias myip='curl ifconfig.me'

# Add more custom commands and environment variables as needed
EOF

    # Ensure the .sys_env file is sourced in the user's shell profile
    SHELL_PROFILE="$HOME/.bashrc"
    if ! grep -q "source $SYS_ENV_FILE" $SHELL_PROFILE; then
        echo "source $SYS_ENV_FILE" >> $SHELL_PROFILE
    fi

    # Notify the user
    echo ".sys_env file created at $SYS_ENV_FILE and added to PATH."
}

# Function to create a directory for `sys-debugger` shell
create_sys_debugger_directory() {
    echo "Creating directory for sys-debugger shell..."

    # Define the directory path
    SYS_DEBUGGER_DIR="$HOME/sys-debugger"

    # Create the directory if it doesn't exist
    if [ ! -d "$SYS_DEBUGGER_DIR" ]; then
        mkdir -p "$SYS_DEBUGGER_DIR"
        echo "Directory created at $SYS_DEBUGGER_DIR."
    else
        echo "Directory already exists at $SYS_DEBUGGER_DIR."
    fi

    # Optionally, set permissions or create subdirectories
    # chmod 755 "$SYS_DEBUGGER_DIR"
    # mkdir -p "$SYS_DEBUGGER_DIR/logs"

    # Notify the user
    echo "Sys-debugger directory setup complete."
}

# Function to start `sys-debugger` shell
start_sys_debugger_shell() {
    echo "Starting sys-debugger shell..."

    # Define the path to the sys-debugger script
    SYS_DEBUGGER_SCRIPT="/usr/local/bin/sys-debugger"

    # Check if the sys-debugger script exists
    if [ -f "$SYS_DEBUGGER_SCRIPT" ]; then
        # Start the sys-debugger shell
        bash --rcfile "$HOME/.sys_env"
    else
        echo "Error: sys-debugger script not found at $SYS_DEBUGGER_SCRIPT."
        echo "Please ensure the sys-debugger script is created and executable."
    fi
}

# Function to display ASCII Art Banner and menu
display_menu() {
    # ASCII Art Banner
    echo "Welcome to the Sys-Debugger Menu"
    echo "Please select an option:"
    echo "1. Status Check of the System (syschk)"
    echo "2. Fix Missing or Broken Packages (fix-broken)"
    echo "3. Security Audit (audit)"
    echo "4. Fix Configuration Settings (fix-config)"
    echo "5. Perform a Backup (backup)"
    echo "6. Exit"
    echo

    # Read user input
    read -p "Enter your choice [1-6]: " choice

    # Handle user input
    case $choice in
        1)
            echo "Starting Status Check of the System..."
            # Call the function for syschk
            ;;
        2)
            echo "Starting Fix Missing or Broken Packages..."
            # Call the function for fix-broken
            ;;
        3)
            echo "Starting Security Audit..."
            # Call the function for audit
            ;;
        4)
            echo "Starting Fix Configuration Settings..."
            # Call the function for fix-config
            ;;
        5)
            echo "Starting Perform a Backup..."
            # Call the function for backup
            ;;
        6)
            echo "Exiting Sys-Debugger. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter a number between 1 and 6."
            display_menu
            ;;
    esac
}

# Main script execution

# Update the system and install necessary packages
update_system

# Create necessary files and directories
create_sys_debugger_directory
create_sys_env_file
create_initialization_file
create_cleanup_file

# Create and start the sys-debugger shell
create_sys_debugger_shell
start_sys_debugger_shell

# Display the menu and handle user interaction
display_menu

# End of script
echo "Thank you for using the Sys-Debugger Script. If you have feedback or issues, open a new issue here: https://github.com/PR-CYBR/PR-CYBR-INFRASTRUCTURE-AGENT/issues"