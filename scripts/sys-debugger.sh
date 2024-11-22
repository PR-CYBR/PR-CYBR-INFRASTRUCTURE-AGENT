#!/bin/bash

# --------------------------------------------- #
# Key Objectives for the System Debugger Script #
# 1. Update system (and install tmux, git, and curl)
# 2. Creates new shell called `sys-debug`
# 3. Creates an initialization file for `sys-debug`
# 4. Creates a cleanup file for `sys-debug`
# 5. Creates a `.sys_env` file for `sys-debug` shell (and sets it in it's PATH)
#   - Sections:
#       - `## System Commands / Aliases / Variables`
#       - `## Network Commands / Aliases / Variables`
#       - `## Git Commands / Aliases / Variables`
#       - `## Docker Commands / Aliases / Variables`
#       - `## TMUX Commands / Aliases / Variables`
#       - `## Zerotier Commands / Aliases / Variables`
# 6. Creates a directory for `sys-debug` shell (and sets it as it's home directory)
# 7. Starts `sys-debug` shell (and sources it's `.sys_env` file to export it's variables)
# 8. Once it's loaded the new shell, have it present the user with an ASCII Art Banner saying "Sys-Debugger Menu", listing the following options:
#       1. Status Check of the System (`syschk``)
#       2. Fix Missing or Broken Packages (`fix-broken`)
#       3. Security Audit (`audit`)
#       4. Fix Configuration Settings (`fix-config`)
#       5. Preform a Backup (`backup`)
# 9. Once the user inputs their choice, create a sub / child shell called it's associate option name (the short version) an loads the userinto that shell
# 10. User Option Routes:
#       1. Status Check of the System (`syschk``)
#           - loads user into new shell
#           - 
#           - creates file called `syschk.txt`
#           - uses `cat` to output (`>`) the following files and their contents into `syschk.txt`:
#               - `/var/log/apache2/*` (access and error logs for the apache web server)
#               - `/var/log/auth.log` (information on user logins, priviliaged access, and remote authentication)
#               - `/var/log/kern.log` (kernel logs)
#               - `/var/log/messages` (general non-critical system information)
#               - `/var/log/syslog` (general system logs)
#       2. Fix Missing or Broken Packages (`fix-broken`)
#           - 
#           - 
#           - 
#       3. Security Audit (`audit`)
#           - 
#           - 
#           - 
#       4. Fix Configuration Settings (`fix-config`)
#           - 
#           - 
#           - 
#       5. Preform a Backup (`backup`)
#           - 
#           - 
#           - 