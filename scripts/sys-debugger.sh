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