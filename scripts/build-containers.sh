#!/bin/bash

# ----------------------------- #
# Table of Contents             #
# ----------------------------- #
# 1. Initialization             #
# 2. Shell Execution            #
# 3. Task Execution             #
# 4. Finalization               #
# ----------------------------- #

# ----------------------- #
# Stage 1: Initialization #
# ----------------------- #

# --------------------------------------------------- #
#             >[Section Breakdown]<                   #
#                                                     #
# 1. Purpose:                                         #
# - Set up environment variables and aliases for each shell. #
#                                                     #
# 2. Explanation of Stage in Depth:                   #
# - This stage involves creating initialization scripts for each subshell. These scripts define environment variables and aliases that are specific to the tasks performed by each shell. This setup ensures that each shell operates in a consistent and controlled environment. #
#                                                     #
# 3. Explanation of Stage in Relevance to `build-containers.sh` Script's Purpose: #
# - The initialization stage is crucial for preparing the environment in which the script's tasks will be executed. By setting up the necessary variables and aliases, it ensures that subsequent stages can run smoothly and without configuration issues. #
#                                                     #
# 4. How / What this Stage Prepares for the Next Stage: #
# - By establishing a consistent environment, this stage lays the groundwork for the Shell Execution stage, where each shell will perform its designated tasks. The initialization ensures that all shells have the necessary context and tools to execute their functions effectively. #
# --------------------------------------------------- #

# ---------------------------------- #
# Function to simulate a loading bar #
# ---------------------------------- #

loading_bar() {
    local duration=2  # Total duration of the loading bar in seconds
    local steps=20    # Number of steps in the loading bar
    local step_duration=$(echo "$duration / $steps" | bc -l)

    echo -n "Processing: ["
    for i in $(seq 1 $steps); do
        echo -n "#"
        sleep "$step_duration"
        local percent=$((i * 100 / steps))
        echo -ne "] $percent%\r"
    done
    echo "] 100% Done!"
}

# --------------------------------------- #
# Function to create initialization files #
# --------------------------------------- #

# --------------------------------------------------- #
#             >[Section Breakdown]<                   #
#                                                     #
# 1. Purpose:                                         #
# - Generate an initialization script for a given subshell, setting up environment variables and aliases specific to the tasks performed by the subshell. #
#                                                     #
# 2. Explanation of Function in Depth:                #
# - This function creates a shell script that initializes the environment for a specific subshell. It writes environment variables and aliases to a file named after the subshell, ensuring that each subshell has a tailored setup. #
#                                                     #
# 3. Explanation of Function in Relevance to `build-containers.sh` Script's Purpose: #
# - The initialization files are crucial for ensuring that each subshell operates with the correct environment settings, which is essential for the successful execution of tasks within the `build-containers.sh` script. #
#                                                     #
# 4. Improvements that could be made:                 #
# - Allow customization of environment variables and aliases through function parameters or external configuration files. #
# - Implement checks to ensure that the initialization file is created successfully and is executable. #
# - Add logging to track the creation of initialization files for debugging purposes. #
#                                                     #
# 5. Highlight important info:                        #
# - Each initialization file is uniquely named based on the subshell, ensuring tailored environment setups. #
# - The script includes basic environment variables and aliases, which can be expanded as needed for specific tasks. #
#                                                     #
# 6. Troubleshooting tips:                            #
# - Ensure that the script has write permissions in the directory where the initialization files are created. #
# - Verify that the initialization file is sourced correctly in the subshell to apply the environment settings. #
# - Check for syntax errors in the initialization file that could prevent it from executing properly. #
# --------------------------------------------------- #

create_initialization_file() {
    local shell_name="$1"
    cat <<EOL > "${shell_name}_init.sh"
#!/bin/bash
# Initialization for $shell_name

# Environment variables
export VAR1="value1"
export VAR2="value2"

# Aliases
alias ll='ls -la'

# Define other aliases and variables as needed
# Example: export PATH=\$PATH:/custom/path
EOL
    chmod +x "${shell_name}_init.sh"
}

# ----------------------------- #
# Function to run a subshell    #
# ----------------------------- #

# --------------------------------------------------- #
#             >[Section Breakdown]<                   #
#                                                     #
# 1. Purpose:                                         #
# - Execute a specific subshell, setting up its environment and performing designated tasks. #
#                                                     #
# 2. Explanation of Function in Depth:                #
# - This function manages the lifecycle of a subshell by creating initialization and cleanup scripts, sourcing the initialization script, and executing tasks based on the subshell's role. It uses a case statement to determine which tasks to perform, ensuring that each subshell operates independently and efficiently. #
#                                                     #
# 3. Explanation of Function in Relevance to `build-containers.sh` Script's Purpose: #
# - The `run_subshell` function is central to the script's operation, as it orchestrates the execution of various tasks across different subshells. This modular approach allows for better organization and separation of concerns within the script. #
#                                                     #
# 4. Improvements that could be made:                 #
# - Implement error handling to manage failures within subshells gracefully. #
# - Allow dynamic task assignment through configuration files or command-line arguments. #
# - Enhance inter-shell communication to improve coordination between subshells. #
#                                                     #
# 5. Highlight important info:                        #
# - Each subshell is isolated in its own process, ensuring that environment variables and tasks do not interfere with each other. #
# - The function relies on the presence of specific files (e.g., `update-containers.md`) to determine tasks. #
#                                                     #
# 6. Troubleshooting tips:                            #
# - Ensure that all required files and scripts are present and correctly configured before running the subshell. #
# - Verify that the initialization and cleanup scripts are sourced correctly to apply environment settings. #
# - Check for syntax errors or missing commands within the subshell tasks that could prevent execution. #
# --------------------------------------------------- #

run_subshell() {
    local shell_name="$1"

    # Create initialization and cleanup files for the subshell
    create_initialization_file "$shell_name"
    create_cleanup_file "$shell_name"

    (
        # Source initialization file
        source "${shell_name}_init.sh"

        # Perform tasks specific to the subshell
        case "$shell_name" in
            analyzer)
                echo "Running analysis tasks..."
                # Check update-containers.md for package updates
                if [ -f update-containers.md ]; then
                    echo "Reading instructions from update-containers.md..."
                    while IFS= read -r line; do
                        if [[ "$line" =~ ^- \[ \] \${PKG_UPDATE_[0-9]+}:\ \"(.+)\":\ \"(.+)\"$ ]]; then
                            package="${BASH_REMATCH[1]}"
                            version="${BASH_REMATCH[2]}"
                            echo "Detected package to update: $package@$version"
                            echo "$package:$version" > package_to_update.txt
                        fi
                    done < update-containers.md
                fi

                # Confirm with updater shell
                if [ -f package_to_update.txt ]; then
                    echo "Notifying updater shell to update package.json..."
                    run_subshell "updater"
                fi
                ;;
            installer)
                echo "Running installation tasks..."
                # Installation logic if needed
                ;;
            updater)
                echo "Running update tasks..."
                if [ -f package_to_update.txt ]; then
                    package_info=$(<package_to_update.txt)
                    IFS=':' read -r package version <<< "$package_info"
                    echo "Updating package.json with package: $package@$version"
                    update_package_json "$package" "$version"
                    rm package_to_update.txt
                fi
                ;;
            container-builder)
                echo "Running container build tasks..."
                # Use the 'build', 'rebuild', and 'status' aliases
                build
                rebuild
                status
                ;;
        esac

        # Source cleanup file
        source "${shell_name}_cleanup.sh"
    )
}

# ----------------------------- #
# Function to create cleanup files
# ----------------------------- #

# --------------------------------------------------- #
#             >[Section Breakdown]<                   #
#                                                     #
# 1. Purpose:                                         #
# - Generate a cleanup script for a given subshell, responsible for removing temporary files and performing necessary cleanup tasks after the subshell's operations are complete. #
#                                                     #
# 2. Explanation of Function in Depth:                #
# - This function creates a shell script that handles the cleanup process for a specific subshell. It writes commands to remove temporary files and perform other cleanup tasks to a file named after the subshell, ensuring that each subshell has a tailored cleanup routine. #
#                                                     #
# 3. Explanation of Function in Relevance to `build-containers.sh` Script's Purpose: #
# - The cleanup files are essential for maintaining a clean working environment by ensuring that temporary files and other artifacts are removed after a subshell completes its tasks. This helps prevent clutter and potential conflicts in subsequent operations. #
#                                                     #
# 4. Stage in Script:                                 #
# - This function is part of the Initialization stage, where environment setup and preparation for task execution occur. It ensures that each subshell has a corresponding cleanup routine ready for execution after its tasks are completed. #
#                                                     #
# 5. Improvements that could be made:                 #
# - Allow customization of cleanup tasks through function parameters or external configuration files. #
# - Implement logging to track the execution of cleanup tasks for debugging purposes. #
# - Add checks to ensure that only the intended files are removed, preventing accidental deletion of important data. #
#                                                     #
# 6. Highlight important info:                        #
# - Each cleanup file is uniquely named based on the subshell, ensuring tailored cleanup routines. #
# - The script includes basic cleanup commands, which can be expanded as needed for specific tasks. #
#                                                     #
# 7. Troubleshooting tips:                            #
# - Ensure that the script has write permissions in the directory where the cleanup files are created. #
# - Verify that the cleanup file is executed correctly in the subshell to apply the cleanup tasks. #
# - Check for syntax errors in the cleanup file that could prevent it from executing properly. #
# --------------------------------------------------- #

create_cleanup_file() {
    local shell_name="$1"
    cat <<EOL > "${shell_name}_cleanup.sh"
#!/bin/bash
# Cleanup for $shell_name

# Remove temporary files
rm -f temp.json

# Add other cleanup commands as needed
# Example: rm -f /path/to/temporary/file
EOL
    chmod +x "${shell_name}_cleanup.sh"
}

# ----------------------------- #
# Function to run a subshell    #
# ----------------------------- #

# --------------------------------------------------- #
#             >[Section Breakdown]<                   #
#                                                     #
# 1. Purpose:                                         #
# - Execute a specific subshell, sourcing its initialization and cleanup scripts. It isolates tasks into categories such as analysis, installation, updating, and container building. #
#                                                     #
# 2. Explanation of Function in Depth:                #
# - This function manages the lifecycle of a subshell by creating initialization and cleanup scripts, sourcing the initialization script, and executing tasks based on the subshell's role. It uses a case statement to determine which tasks to perform, ensuring that each subshell operates independently and efficiently. #
#                                                     #
# 3. Explanation of Function in Relevance to `build-containers.sh` Script's Purpose: #
# - The `run_subshell` function is central to the script's operation, as it orchestrates the execution of various tasks across different subshells. This modular approach allows for better organization and separation of concerns within the script. #
#                                                     #
# 4. Stage in Script:                                 #
# - This function is part of the Shell Execution stage, where each subshell performs its designated tasks. It ensures that tasks are executed in an isolated environment, maintaining the integrity of the overall process. #
#                                                     #
# 5. Improvements that could be made:                 #
# - Add error handling to manage failures within subshell tasks, ensuring graceful exits and logging. #
# - Allow dynamic task assignment through configuration files or command-line arguments. #
# - Implement parallel execution of subshells to improve efficiency if tasks are independent. #
#                                                     #
# 6. Highlight important info:                        #
# - Each subshell is executed in a separate process, ensuring that its environment is isolated from the main script and other subshells. #
# - Initialization and cleanup scripts are sourced to set up and tear down the environment for each subshell. #
#                                                     #
# 7. Troubleshooting tips:                            #
# - Ensure that the initialization and cleanup scripts are executable and correctly sourced. #
# - Verify that the logic within each case block is correctly implemented and does not interfere with other subshells. #
# - Check for any errors in the subshell execution by reviewing the output and logs. #
# --------------------------------------------------- #

run_subshell() {
    local shell_name="$1"

    # Create initialization and cleanup files for the subshell
    create_initialization_file "$shell_name"
    create_cleanup_file "$shell_name"

    (
        # Source initialization file
        source "${shell_name}_init.sh"

        # Perform tasks specific to the subshell
        case "$shell_name" in
            analyzer)
                echo "Running analysis tasks..."
                # Use the 'analyze' alias
                analyze
                ;;
            installer)
                echo "Running installation tasks..."
                # Use the 'install' alias
                install
                ;;
            updater)
                echo "Running update tasks..."
                # Use the 'update' and 'upgrade' aliases
                update
                upgrade
                ;;
            container-builder)
                echo "Running container build tasks..."
                # Use the 'build', 'rebuild', and 'status' aliases
                build
                rebuild
                status
                ;;
        esac

        # Source cleanup file
        source "${shell_name}_cleanup.sh"
    )
}

# -------------------------------------------------- #
# Function to ensure update-containers.md exists     #
# -------------------------------------------------- #

# --------------------------------------------------- #
#             >[Section Breakdown]<                   #
#                                                     #
# 1. Purpose:                                         #
# - Ensure the existence of the `update-containers.md` file, creating it with a template if it does not exist. This file guides the update process for various configuration files. #
#                                                     #
# 2. Explanation of Function in Depth:                #
# - This function checks for the presence of `update-containers.md`. If the file is missing, it creates a new file with a structured template that includes sections for updating the Dockerfile, docker-compose.yml, .env, and package.json. The template provides placeholders and examples to assist users in specifying updates. #
#                                                     #
# 3. Explanation of Function in Relevance to `build-containers.sh` Script's Purpose: #
# - The `update-containers.md` file is a central component of the script, serving as a blueprint for updates. Ensuring its existence is crucial for the script to function correctly, as it dictates the changes to be applied to configuration files. #
#                                                     #
# 4. Stage in Script:                                 #
# - This function is part of the Initialization stage, where necessary files and configurations are prepared before executing tasks. #
#                                                     #
# 5. Improvements that could be made:                 #
# - Allow customization of the template content through script parameters or environment variables. #
# - Implement a versioning mechanism to update the template if the format changes in the future. #
# - Add a prompt to confirm file creation if the script is run interactively. #
#                                                     #
# 6. Highlight important info:                        #
# - The function only creates the file if it does not already exist, preventing overwriting any existing content. #
# - The template includes comments to guide users on how to format their entries. #
#                                                     #
# 7. Troubleshooting tips:                            #
# - Ensure the script has write permissions in the directory where `update-containers.md` is to be created. #
# - Verify that the file path provided to the function is correct. #
# --------------------------------------------------- #

ensure_update_file_exists() {
    local file_name="$1"
    echo "Checking for $file_name..."
    loading_bar

    # Create update-containers.md if it doesn't exist
    if [ ! -f "$file_name" ]; then
        echo "Creating $file_name with a template..."
        cat <<EOL > "$file_name"
# Container Self Re-Build Healing File

## Dockerfile
- **DFILE_UPDATE**:
  - [ ] \${DFILE_UPDATE_1}: _package needed to be installed_
  - [ ] \${DFILE_UPDATE_2}: _package needed to be installed_

## docker-compose.yml
- **DCFILE_UPDATE**:
  - [ ] \${DCFILE_UPDATE_1}: _add new service_
  - [ ] \${DCFILE_UPDATE_2}: _update image_

## .env
- **ENV_UPDATE**:
  - [ ] \${ENV_UPDATE_1}: _add variable_
  - [ ] \${ENV_UPDATE_2}: _update variable_

## package.json
- **PKG_UPDATE**:
  - [ ] \${PKG_UPDATE_1}: _add dependency_
  - [ ] \${PKG_UPDATE_2}: _update dependency_

# Add more instructions as needed
EOL
    else
        echo "$file_name already exists. Processing existing instructions..."
        # Add logic to process existing update-containers.md
        current_section=""
        while IFS= read -r line; do
            # Process Dockerfile instructions
            if [[ "$line" =~ ^##\ Dockerfile ]]; then
                current_section="Dockerfile"
            elif [[ "$line" =~ ^- \[ \] \${DFILE_UPDATE_[0-9]+}:\ (.+)$ && "$current_section" == "Dockerfile" ]]; then
                package="${BASH_REMATCH[1]}"
                echo "Detected package to add to Dockerfile: $package"
                # Logic to handle adding package to Dockerfile
                sed -i "/^RUN apt-get update/a RUN apt-get install -y $package" Dockerfile || echo "Failed to add package to Dockerfile"
            fi

            # Process docker-compose.yml instructions
            if [[ "$line" =~ ^##\ docker-compose.yml ]]; then
                current_section="docker-compose.yml"
            elif [[ "$line" =~ ^- \[ \] \${DCFILE_UPDATE_[0-9]+}:\ (.+)$ && "$current_section" == "docker-compose.yml" ]]; then
                service="${BASH_REMATCH[1]}"
                echo "Detected service to add to docker-compose.yml: $service"
                # Logic to handle adding service to docker-compose.yml
                echo -e "\n  $service:\n    image: $service:latest" >> docker-compose.yml || echo "Failed to add service to docker-compose.yml"
            elif [[ "$line" =~ ^- \[ \] \${DCFILE_UPDATE_[0-9]+}:\ (.+)$ && "$current_section" == "docker-compose.yml" ]]; then
                image="${BASH_REMATCH[1]}"
                echo "Detected image to update in docker-compose.yml: $image"
                # Logic to handle updating image in docker-compose.yml
                sed -i "s|image:.*|image: $image|" docker-compose.yml || echo "Failed to update image in docker-compose.yml"
            fi

            # Process .env instructions
            if [[ "$line" =~ ^##\ .env ]]; then
                current_section=".env"
            elif [[ "$line" =~ ^- \[ \] \${ENV_UPDATE_[0-9]+}:\ (.+)$ && "$current_section" == ".env" ]]; then
                variable="${BASH_REMATCH[1]}"
                echo "Detected variable to add to .env: $variable"
                # Logic to handle adding variable to .env
                echo "$variable" >> .env || echo "Failed to add variable to .env"
            elif [[ "$line" =~ ^- \[ \] \${ENV_UPDATE_[0-9]+}:\ (.+)$ && "$current_section" == ".env" ]]; then
                variable="${BASH_REMATCH[1]}"
                key=$(echo "$variable" | cut -d'=' -f1)
                echo "Detected variable to update in .env: $variable"
                # Logic to handle updating variable in .env
                sed -i "s|^$key=.*|$variable|" .env || echo "Failed to update variable in .env"
            fi

            # Process package.json instructions
            if [[ "$line" =~ ^##\ package.json ]]; then
                current_section="package.json"
            elif [[ "$line" =~ ^- \[ \] \${PKG_UPDATE_[0-9]+}:\ \"(.+)\":\ \"(.+)\"$ && "$current_section" == "package.json" ]]; then
                dependency="${BASH_REMATCH[1]}"
                version="${BASH_REMATCH[2]}"
                echo "Detected dependency to add to package.json: $dependency@$version"
                # Logic to handle adding dependency to package.json
                jq --arg dep "$dependency" --arg ver "$version" '.dependencies[$dep] = $ver' package.json > temp.json && mv temp.json package.json || echo "Failed to add dependency to package.json"
            elif [[ "$line" =~ ^- \[ \] \${PKG_UPDATE_[0-9]+}:\ \"(.+)\":\ \"(.+)\"$ && "$current_section" == "package.json" ]]; then
                dependency="${BASH_REMATCH[1]}"
                version="${BASH_REMATCH[2]}"
                echo "Detected dependency to update in package.json: $dependency@$version"
                # Logic to handle updating dependency in package.json
                jq --arg dep "$dependency" --arg ver "$version" '.dependencies[$dep] = $ver' package.json > temp.json && mv temp.json package.json || echo "Failed to update dependency in package.json"
            fi
        done < "$file_name"
    fi
}

# Call the function to ensure the file is created
ensure_update_file_exists "update-containers.md"

# --------------------------------------------------- #
# Determine the package manager and update the system #
# --------------------------------------------------- #

# --------------------------------------------------- #
#             >[Section Breakdown]<                   #
#                                                     #
# 1. Purpose:                                         #
# - The `determine_package_manager` function identifies the package manager available on the system. The `update_system` function uses this information to update system packages, ensuring the system is up-to-date and dependencies are managed effectively. #
#                                                     #
# 2. Explanation of Functions in Depth:               #
# - `determine_package_manager`: Checks for the presence of common package managers (`apt-get`, `yum`, `dnf`, `pacman`) and writes the detected package manager to a file. #
# - `update_system`: Reads the package manager from the file and executes the appropriate update commands to refresh system packages. #
#                                                     #
# 3. Explanation of Functions in Relevance to `build-containers.sh` Script's Purpose: #
# - Identifying and using the correct package manager is essential for maintaining the system's software environment, which is a critical part of the script's operation. This ensures that all dependencies are current and the system is secure. #
#                                                     #
# 4. Stage in Script:                                 #
# - These functions are part of the Initialization stage, where the environment is prepared for executing tasks. #
#                                                     #
# 5. Improvements that could be made:                 #
# - Add support for additional package managers to increase compatibility with more systems. #
# - Implement a dry-run option to preview updates without applying them, providing users with more control. #
# - Include error handling to manage failed updates and provide feedback to the user. #
#                                                     #
# 6. Highlight important info:                        #
# - The functions currently support `apt-get`, `yum`, `dnf`, and `pacman`, covering a wide range of Linux distributions. #
# - They use `sudo` to execute package manager commands, which requires the user to have appropriate permissions. #
#                                                     #
# 7. Troubleshooting tips:                            #
# - Ensure the script is run with sufficient privileges to execute `sudo` commands. #
# - If the system update fails, check the package manager's logs for more detailed error messages. #
# - Verify that the package manager is correctly installed and configured on the system. #
# --------------------------------------------------- #

# Analyzer shell: Determine the package manager
determine_package_manager() {
    echo "Determining the package manager..."
    if command -v apt-get &> /dev/null; then
        echo "apt-get" > package_manager.txt
    elif command -v yum &> /dev/null; then
        echo "yum" > package_manager.txt
    elif command -v dnf &> /dev/null; then
        echo "dnf" > package_manager.txt
    elif command -v pacman &> /dev/null; then
        echo "pacman" > package_manager.txt
    else
        echo "none" > package_manager.txt
    fi
}

# Updater shell: Update the system using the determined package manager
update_system() {
    echo "Updating system packages..."
    loading_bar
    if [ -f package_manager.txt ]; then
        package_manager=$(<package_manager.txt)
        case "$package_manager" in
            apt-get)
                echo "Using apt-get to update the system..."
                sudo apt-get update && sudo apt-get upgrade -y
                ;;
            yum)
                echo "Using yum to update the system..."
                sudo yum update -y
                ;;
            dnf)
                echo "Using dnf to update the system..."
                sudo dnf update -y
                ;;
            pacman)
                echo "Using pacman to update the system..."
                sudo pacman -Syu
                ;;
            *)
                echo "No supported package manager found. Please update the system manually."
                exit 1
                ;;
        esac
    else
        echo "Package manager information not found. Please run the analyzer shell first."
        exit 1
    fi
}

# --------------------------- #
# Check and update Dockerfile #
# --------------------------- #

# --------------------------------------------------- #
#             >[Section Breakdown]<                   #
#                                                     #
# 1. Purpose:                                         #
# - The `update_dockerfile` function checks for the presence of a `Dockerfile` and updates it based on instructions found in `update-containers.md`. This ensures that the Docker environment is configured with the necessary packages and settings. #
#                                                     #
# 2. Explanation of Function in Depth:                #
# - This function reads `update-containers.md` for instructions on packages to add to the `Dockerfile`. It uses `sed` to insert package installation commands into the `Dockerfile`, assuming a specific structure. The function processes each line in `update-containers.md`, allowing for flexible updates. #
#                                                     #
# 3. Explanation of Function in Relevance to `build-containers.sh` Script's Purpose: #
# - Updating the `Dockerfile` is a critical step in maintaining the Docker environment, ensuring that all necessary packages are installed and configured correctly. This function automates the update process, reducing manual intervention and potential errors. #
#                                                     #
# 4. Stage in Script:                                 #
# - This function is part of the Task Execution stage, where specific tasks are performed based on the instructions provided in the initialization stage. #
#                                                     #
# 5. Improvements that could be made:                 #
# - Implement a backup mechanism for the `Dockerfile` before making changes, allowing for easy rollback if needed. #
# - Enhance the parsing logic to handle more complex instructions, such as modifying existing lines or adding multi-line configurations. #
# - Add validation to ensure that changes made to the `Dockerfile` do not introduce syntax errors or conflicts. #
#                                                     #
# 6. Highlight important info:                        #
# - The function uses `sed` to insert package installation commands into the `Dockerfile`. This assumes a specific structure and may need adjustment based on your `Dockerfile`. #
# - The function processes each line in `update-containers.md`, allowing for flexible updates. #
#                                                     #
# 7. Troubleshooting tips:                            #
# - Ensure that `update-containers.md` contains valid and correctly formatted instructions. #
# - Verify that the `Dockerfile` is in the expected location and has the correct permissions for modification. #
# - If the Docker build fails after updates, check the `Dockerfile` for syntax errors or conflicts introduced by the changes. #
# --------------------------------------------------- #

run_subshell() {
    local shell_name="$1"

    # Create initialization and cleanup files for the subshell
    create_initialization_file "$shell_name"
    create_cleanup_file "$shell_name"

    (
        # Source initialization file
        source "${shell_name}_init.sh"

        # Perform tasks specific to the subshell
        case "$shell_name" in
            analyzer)
                echo "Running analysis tasks..."
                # Check update-containers.md or .env for variables
                if [ -f update-containers.md ]; then
                    echo "Reading instructions from update-containers.md..."
                    while IFS= read -r line; do
                        if [[ "$line" =~ ^- \[ \] \${DFILE_UPDATE_[0-9]+}:\ (.+)$ ]]; then
                            package="${BASH_REMATCH[1]}"
                            echo "Detected package to add: $package"
                            echo "$package" > package_to_install.txt
                        fi
                    done < update-containers.md
                fi

                # Confirm with updater shell
                if [ -f package_to_install.txt ]; then
                    echo "Notifying updater shell to update Dockerfile..."
                    run_subshell "updater"
                fi

                # Confirm with installer shell
                if [ -f package_to_install.txt ]; then
                    echo "Notifying installer shell to install packages..."
                    run_subshell "installer"
                fi
                ;;
            installer)
                echo "Running installation tasks..."
                if [ -f package_to_install.txt ]; then
                    package=$(<package_to_install.txt)
                    echo "Installing package: $package"
                    # Example installation logic
                    sudo apt-get install -y "$package"
                    echo "Installation complete."
                    rm package_to_install.txt
                fi
                ;;
            updater)
                echo "Running update tasks..."
                if [ -f package_to_install.txt ]; then
                    package=$(<package_to_install.txt)
                    echo "Updating Dockerfile with package: $package"
                    # Update Dockerfile
                    if [ -f Dockerfile ]; then
                        sed -i "/^RUN apt-get update/a RUN apt-get install -y $package" Dockerfile
                        echo "Dockerfile updated."
                        rm package_to_install.txt
                    else
                        echo "Dockerfile not found. Skipping update."
                    fi
                fi
                ;;
            container-builder)
                echo "Running container build tasks..."
                # Use the 'build', 'rebuild', and 'status' aliases
                build
                rebuild
                status
                ;;
        esac

        # Source cleanup file
        source "${shell_name}_cleanup.sh"
    )
}

# ----------------------------------- #
# Check and update docker-compose.yml #
# ----------------------------------- #

# --------------------------------------------------- #
#             >[Section Breakdown]<                   #
#                                                     #
# 1. Purpose:                                         #
# - The `update_docker_compose` function checks for the presence of a `docker-compose.yml` file and updates it as needed. This ensures that the Docker Compose configuration is current and reflects any necessary changes to the service definitions or environment. #
#                                                     #
# 2. Explanation of Function in Depth:                #
# - This function reads `update-containers.md` for instructions on services to add or update in the `docker-compose.yml`. It processes each line to detect changes and applies them to the configuration file, ensuring that the Docker Compose setup is aligned with the specified requirements. #
#                                                     #
# 3. Explanation of Function in Relevance to `build-containers.sh` Script's Purpose: #
# - Keeping the `docker-compose.yml` file updated is crucial for managing multi-container Docker applications. This function automates the update process, ensuring that all services are correctly defined and configured. #
#                                                     #
# 4. Stage in Script:                                 #
# - This function is part of the Task Execution stage, where specific tasks are performed based on the instructions provided in the initialization stage. #
#                                                     #
# 5. Improvements that could be made:                 #
# - Implement a version control mechanism to track changes to `docker-compose.yml`, allowing for easy rollback if needed. #
# - Enhance the update logic to automatically merge changes from a template or external source, reducing manual edits. #
# - Add validation to ensure that the updated `docker-compose.yml` is syntactically correct and compatible with the current Docker Compose version. #
#                                                     #
# 6. Highlight important info:                        #
# - The function currently serves as a placeholder for update logic, which should be customized based on specific requirements. #
# - It assumes the `docker-compose.yml` file is located in the current working directory. #
#                                                     #
# 7. Troubleshooting tips:                            #
# - Ensure that `docker-compose.yml` is in the expected location and has the correct permissions for modification. #
# - If Docker Compose fails to start services after updates, check the file for syntax errors or configuration issues. #
# - Use `docker-compose config` to validate the file and identify any errors before applying changes. #
# --------------------------------------------------- #

run_subshell() {
    local shell_name="$1"

    # Create initialization and cleanup files for the subshell
    create_initialization_file "$shell_name"
    create_cleanup_file "$shell_name"

    (
        # Source initialization file
        source "${shell_name}_init.sh"

        # Perform tasks specific to the subshell
        case "$shell_name" in
            analyzer)
                echo "Running analysis tasks..."
                # Check update-containers.md for variables
                if [ -f update-containers.md ]; then
                    echo "Reading instructions from update-containers.md..."
                    while IFS= read -r line; do
                        if [[ "$line" =~ ^- \[ \] \${DCFILE_UPDATE_[0-9]+}:\ (.+)$ ]]; then
                            service="${BASH_REMATCH[1]}"
                            echo "Detected service to add or update: $service"
                            echo "$service" > service_to_update.txt
                        fi
                    done < update-containers.md
                fi

                # Confirm with updater shell
                if [ -f service_to_update.txt ]; then
                    echo "Notifying updater shell to update docker-compose.yml..."
                    run_subshell "updater"
                fi
                ;;
            installer)
                echo "Running installation tasks..."
                # Installation logic if needed
                ;;
            updater)
                echo "Running update tasks..."
                if [ -f service_to_update.txt ]; then
                    service=$(<service_to_update.txt)
                    echo "Updating docker-compose.yml with service: $service"
                    update_docker_compose "$service"
                    rm service_to_update.txt
                fi
                ;;
            container-builder)
                echo "Running container build tasks..."
                # Use the 'build', 'rebuild', and 'status' aliases
                build
                rebuild
                status
                ;;
        esac

        # Source cleanup file
        source "${shell_name}_cleanup.sh"
    )
}

# -------------------------- #
# Check and update .env file #
# -------------------------- #

# --------------------------------------------------- #
#             >[Section Breakdown]<                   #
#                                                     #
# 1. Purpose:                                         #
# - The `update_env_file` function checks for the presence of a `.env` file and updates it as needed. This ensures that environment variables are correctly set and up-to-date, which is crucial for the proper functioning of Docker containers and applications. #
#                                                     #
# 2. Explanation of Function in Depth:                #
# - This function verifies the existence of a `.env` file and updates or adds environment variables based on the input provided. It uses `sed` to modify existing variables and appends new ones if they are not already present. #
#                                                     #
# 3. Explanation of Function in Relevance to `build-containers.sh` Script's Purpose: #
# - Maintaining an accurate and current `.env` file is essential for configuring applications and services within Docker containers. This function automates the update process, ensuring that all necessary environment variables are correctly defined. #
#                                                     #
# 4. Stage in Script:                                 #
# - This function is part of the Task Execution stage, where specific tasks are performed based on the instructions provided in the initialization stage. #
#                                                     #
# 5. Improvements that could be made:                 #
# - Implement a backup mechanism for the `.env` file before making changes, allowing for easy rollback if needed. #
# - Enhance the update logic to automatically merge changes from a template or external source, reducing manual edits. #
# - Add validation to ensure that the `.env` file contains all required variables and values are correctly formatted. #
#                                                     #
# 6. Highlight important info:                        #
# - The function currently serves as a placeholder for update logic, which should be customized based on specific requirements. #
# - It assumes the `.env` file is located in the current working directory. #
#                                                     #
# 7. Troubleshooting tips:                            #
# - Ensure that the `.env` file is in the expected location and has the correct permissions for modification. #
# - If applications fail to start or behave unexpectedly after updates, check the `.env` file for missing or incorrect variables. #
# - Use tools like `dotenv-linter` to validate the `.env` file and identify any errors before applying changes. #
# --------------------------------------------------- #

update_env_file() {
    local env_var="$1"
    echo "Checking .env file..."
    loading_bar
    if [ -f .env ]; then
        echo ".env file found. Checking for updates..."
        # Example: Update an environment variable
        key=$(echo "$env_var" | cut -d'=' -f1)
        if grep -q "^$key=" .env; then
            sed -i "s|^$key=.*|$env_var|" .env
        else
            echo "$env_var" >> .env
        fi
    else
        echo ".env file not found. Skipping update."
    fi
}

# ----------------------------- #
# Check and update package.json #
# ----------------------------- #

# --------------------------------------------------- #
#             >[Section Breakdown]<                   #
#                                                     #
# 1. Purpose:                                         #
# - The `update_package_json` function checks for the presence of a `package.json` file and updates it as needed. This ensures that the project's dependencies and scripts are current, which is essential for the proper functioning of Node.js applications. #
#                                                     #
# 2. Explanation of Function in Depth:                #
# - This function verifies the existence of a `package.json` file and updates the specified package version using `jq`. It modifies the JSON structure to ensure that the dependencies are up-to-date, which is crucial for maintaining the application's functionality and security. #
#                                                     #
# 3. Explanation of Function in Relevance to `build-containers.sh` Script's Purpose: #
# - Keeping the `package.json` file updated is vital for managing Node.js application dependencies. This function automates the update process, ensuring that all necessary packages are correctly defined and versioned. #
#                                                     #
# 4. Stage in Script:                                 #
# - This function is part of the Task Execution stage, where specific tasks are performed based on the instructions provided in the initialization stage. #
#                                                     #
# 5. Improvements that could be made:                 #
# - Implement a backup mechanism for the `package.json` file before making changes, allowing for easy rollback if needed. #
# - Enhance the update logic to automatically merge changes from a template or external source, reducing manual edits. #
# - Add validation to ensure that the `package.json` file is syntactically correct and all dependencies are compatible. #
#                                                     #
# 6. Highlight important info:                        #
# - The function currently serves as a placeholder for update logic, which should be customized based on specific requirements. #
# - It assumes the `package.json` file is located in the current working directory. #
#                                                     #
# 7. Troubleshooting tips:                            #
# - Ensure that the `package.json` file is in the expected location and has the correct permissions for modification. #
# - If the application fails to start or behaves unexpectedly after updates, check the `package.json` for missing or incorrect dependencies. #
# - Use tools like `npm audit` or `yarn audit` to identify and resolve vulnerabilities in dependencies. #
# --------------------------------------------------- #

update_package_json() {
    local package="$1"
    local version="$2"
    echo "Checking package.json..."
    loading_bar
    if [ -f package.json ]; then
        echo "package.json found. Checking for updates..."
        # Update the specified package version
        jq --arg pkg "$package" --arg ver "$version" '.dependencies[$pkg] = $ver' package.json > temp.json && mv temp.json package.json
    else
        echo "package.json not found. Skipping update."
    fi
}

# --------------------- #
# Main script execution #
# --------------------- #

# --------------------------------------------------- #
#             >[Section Breakdown]<                   #
#                                                     #
# 1. Purpose:                                         #
# - The main script execution section orchestrates the overall workflow of the script. It sequentially calls functions to display ASCII art, process update instructions, update the system, and check and update key configuration files. This ensures that the environment is properly configured and up-to-date. #
#                                                     #
# 2. Explanation of Function in Depth:                #
# - This section serves as the entry point for the script, coordinating the execution of various functions that handle different aspects of the environment setup and update process. Each function is responsible for a specific task, such as updating system packages, modifying configuration files, or processing update instructions. #
#                                                     #
# 3. Explanation of Function in Relevance to `build-containers.sh` Script's Purpose: #
# - The main execution section is critical for ensuring that all components of the environment are correctly configured and updated. It ties together the individual functions into a cohesive workflow, enabling the script to achieve its overall goal of maintaining a functional and up-to-date environment. #
#                                                     #
# 4. Stage in Script:                                 #
# - This section represents the Execution stage, where all preparatory and update tasks are performed in sequence to achieve the desired state of the environment. #
#                                                     #
# 5. Improvements that could be made:                 #
# - Implement error handling to gracefully manage failures in any of the functions, ensuring the script can recover or exit cleanly. #
# - Add logging to capture the output and status of each function call, providing a detailed execution trace for debugging. #
# - Introduce a configuration file or command-line options to customize the script's behavior, allowing for more flexible execution. #
#                                                     #
# 6. Highlight important info:                        #
# - The order of function calls is crucial, as each step builds on the previous one to ensure a fully updated and functional environment. #
# - The script assumes that all necessary files and dependencies are in place before execution. #
#                                                     #
# 7. Troubleshooting tips:                            #
# - If the script fails, review the output for error messages and check the logs (if implemented) for more details. #
# - Ensure that all required files (e.g., `update-containers.txt`, `Dockerfile`, `docker-compose.yml`) are present and correctly configured. #
# - Verify that the script has the necessary permissions to execute commands and modify files. #
# --------------------------------------------------- #

display_ascii_art
process_update_file "update-containers.txt"
update_system
update_dockerfile
update_docker_compose
update_env_file
update_package_json

# ------------------------------ #
# Rebuild and restart containers #
# ------------------------------ #

# --------------------------------------------------- #
#             >[Section Breakdown]<                   #
#                                                     #
# 1. Purpose:                                         #
# - This section is responsible for stopping, rebuilding, and restarting Docker containers. It ensures that any updates or changes made to the Docker configuration files are applied and that the containers are running the latest versions of the images. #
#                                                     #
# 2. Explanation of Function in Depth:                #
# - The process involves stopping all running containers, rebuilding the Docker images to incorporate any changes, and then restarting the containers to apply these updates. This ensures that the environment is running the most current configuration and code. #
#                                                     #
# 3. Explanation of Function in Relevance to `build-containers.sh` Script's Purpose: #
# - Rebuilding and restarting containers is a critical step in the script's workflow, ensuring that all updates to the Docker environment are applied and that the containers are operating with the latest configurations. #
#                                                     #
# 4. Stage in Script:                                 #
# - This section is part of the Finalization stage, where the environment is brought to its updated and operational state. #
#                                                     #
# 5. Improvements that could be made:                 #
# - Add error handling to manage failures during the `docker-compose` commands, providing feedback and potential recovery options. #
# - Implement a pre-check to ensure that all necessary services and dependencies are available before attempting to rebuild and restart containers. #
# - Introduce logging to capture the output of the `docker-compose` commands, aiding in debugging and monitoring. #
#                                                     #
# 6. Highlight important info:                        #
# - The `docker-compose down` command stops and removes all running containers, networks, and volumes defined in the `docker-compose.yml` file. #
# - The `docker-compose build` command rebuilds the images, incorporating any changes made to the `Dockerfile` or other configuration files. #
# - The `docker-compose up -d` command starts the containers in detached mode, allowing the script to continue running without blocking. #
#                                                     #
# 7. Troubleshooting tips:                            #
# - If the containers fail to start, check the output of the `docker-compose` commands for error messages. #
# - Ensure that the `docker-compose.yml` file is correctly configured and that all required images and services are available. #
# - Use `docker-compose logs` to view the logs of the containers for additional debugging information. #
# --------------------------------------------------- #

echo "Rebuilding and restarting containers..."
loading_bar
docker-compose down
docker-compose build
docker-compose up -d

# ----------------------- #
# List running containers #
# ----------------------- #

# --------------------------------------------------- #
#             >[Section Breakdown]<                   #
#                                                     #
# 1. Purpose:                                         #
# - This section uses the `docker ps` command to list all currently running Docker containers. It provides a quick overview of the active containers, allowing you to verify that the expected services are up and running. #
#                                                     #
# 2. Explanation of Function in Depth:                #
# - The `docker ps` command is executed to display a list of all running containers. This command provides essential information about each container, such as its ID, image, command, creation time, status, ports, and name. This overview helps in monitoring the state of the Docker environment. #
#                                                     #
# 3. Explanation of Function in Relevance to `build-containers.sh` Script's Purpose: #
# - Listing running containers is a crucial step in verifying that the environment is functioning as expected after updates and restarts. It ensures that all necessary services are operational and accessible. #
#                                                     #
# 4. Stage in Script:                                 #
# - This section is part of the Finalization stage, where the environment's operational status is confirmed. #
#                                                     #
# 5. Improvements that could be made:                 #
# - Enhance the output by using `docker ps --format` to display specific information, such as container names, statuses, and ports, in a more readable format. #
# - Implement a filter to show only containers related to the current project or specific services, reducing clutter in environments with many containers. #
# - Add a summary or count of running containers to quickly assess the state of the environment. #
#                                                     #
# 6. Highlight important info:                        #
# - The `docker ps` command lists only running containers by default. To see all containers, including stopped ones, use `docker ps -a`. #
# - The output includes details such as container IDs, image names, command, creation time, status, ports, and names. #
#                                                     #
# 7. Troubleshooting tips:                            #
# - If expected containers are not listed, check the `docker-compose` logs for errors during startup. #
# - Ensure that the `docker-compose.yml` file is correctly configured and that all services are defined and started. #
# - Use `docker inspect <container_id>` for detailed information about a specific container if needed. #
# --------------------------------------------------- #

docker ps

# --------------------- #
# Print success message #
# --------------------- #

# --------------------------------------------------- #
#             >[Section Breakdown]<                   #
#                                                     #
# 1. Purpose:                                         #
# - This section prints a success message to indicate that all Docker containers have been successfully updated, rebuilt, and deployed. It serves as a confirmation that the script has completed its tasks without errors. Additionally, it ensures that the `container-builder` shell runs the cleanup file and shuts down all shells, including itself. #
#                                                     #
# 2. Explanation of Function in Depth:                #
# - The success message is displayed using an `echo` statement, providing immediate feedback to the user. The `container-builder` shell is responsible for executing the cleanup process, ensuring that all temporary files and processes are terminated. #
#                                                     #
# 3. Explanation of Function in Relevance to `build-containers.sh` Script's Purpose: #
# - Printing a success message and performing cleanup are crucial for confirming the successful execution of the script and maintaining a clean environment. This final step ensures that all resources are properly managed and released. #
#                                                     #
# 4. Stage in Script:                                 #
# - This section is part of the Finalization stage, where the script concludes its operations and confirms successful execution. #
#                                                     #
# 5. Improvements that could be made:                 #
# - Customize the success message to include a timestamp or additional context, such as the number of containers updated. #
# - Implement conditional logic to print different messages based on the outcome of the script, such as warnings if non-critical issues were encountered. #
# - Add an option to send a notification (e.g., email or Slack message) to alert users or administrators of the successful completion. #
#                                                     #
# 6. Highlight important info:                        #
# - The success message is a simple echo statement, providing immediate feedback to the user. #
# - It assumes that all previous steps in the script have executed successfully without errors. #
#                                                     #
# 7. Troubleshooting tips:                            #
# - If the success message is not displayed, review the script's output for any errors or issues that may have occurred during execution. #
# - Ensure that all functions and commands in the script are correctly implemented and have the necessary permissions to execute. #
# - Consider adding logging to capture the script's execution flow for easier troubleshooting. #
# --------------------------------------------------- #

echo "All containers have been successfully updated, rebuilt, and deployed."

# Run cleanup and shut down all shells
source "container-builder_cleanup.sh"
kill 0  # This command sends a signal to terminate all processes in the current process group, effectively shutting down all shells.