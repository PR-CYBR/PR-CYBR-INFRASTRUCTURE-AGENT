#!/bin/bash

# --------------------------------------------- #
# Key Objectives for the Network Debugger Script #
# 1. Update system
# 2. Creates new shell called `net-debug`
# 3. Creates an initialization file for `net-debug`
# 4. Creates a cleanup file for `net-debug`
# 5. Creates a `.net_env` file for `net-debug` (and sets it in it's PATH)
#   - Sections:
#       - `## System Commands / Aliases / Variables`
#       - `## Network Commands / Aliases / Variables`
#       - `## Git Commands / Aliases / Variables`
#       - `## Docker Commands / Aliases / Variables`
#       - `## TMUX Commands / Aliases / Variables`
#       - `## Zerotier Commands / Aliases / Variables`
# 6. Creates a directory for `net-debug` shell (and sets it as it's home directory)
# 7. Starts `net-debug` shell (and sources it's `.net_env` file to export it's variables)
# 8. Once it's loaded the new shell, have it present the user with an ASCII Art Banner saying "Net-Debugger Menu", listing the following options:
#       1. Summary of Current Network Configuration (`netsum`)
#       2. List Open Ports (`lop`)
#       3. List what services are listening to what ports (`lsl`)
#       4. Network Security Audit (`net-audit`)
#       5. Fix Configuration Settings (`fix-config`)
# 9. Once the user inputs their choice, create a sub / child detached background shell called it's associate option name (the short version)
# 10. User Option Routes:
#       1. Summary of Current Network Configuration (`netsum`)
#           - loads user into new shell called `netsum`
#           - creates new file called `net-debugger-netsum.log`
#           - sources `.net_env` file to export enviornment variables
#           - prompts user to choose from a list of options:
#              - 
#              - 
#           - runs cleanup script to remove the files it created (execept for the `backup-sys-debugger.log` file), then kills the shell to return to the parent shell
#       2. List Open Ports (`lop`)
#           - loads user into new shell called `lop`
#           - creates new file called `net-debugger-lop.log`
#           - sources `.net_env` file to export enviornment variables
#           - prompts user to choose from a list of options:
#              - 
#              - 
#           - runs cleanup script to remove the files it created (execept for the `backup-sys-debugger.log` file), then kills the shell to return to the parent shell
#       3. List what services are listening to what ports (`lsl`)
#           - loads user into new shell called `lsl`
#           - creates new file called `net-debugger-lsl.log`
#           - sources `.net_env` file to export enviornment variables
#           - prompts user to choose from a list of options:
#              - 
#              - 
#           - runs cleanup script to remove the files it created (execept for the `backup-sys-debugger.log` file), then kills the shell to return to the parent shell
#       4. Network Security Audit (`net-audit`)
#           - loads user into new shell called `net-audit`
#           - creates new file called `net-debugger-net-audit.log`
#           - sources `.net_env` file to export enviornment variables
#           - prompts user to choose from a list of options:
#              - 
#              - 
#           - runs cleanup script to remove the files it created (execept for the `backup-sys-debugger.log` file), then kills the shell to return to the parent shell
#       5. Fix Configuration Settings (`fix-config`)
#           - loads user into new shell called `fix-config`
#           - creates new file called `net-debugger-fix-config.log`
#           - sources `.net_env` file to export enviornment variables
#           - prompts user to choose from a list of options:
#              - 
#              - 
#           - runs cleanup script to remove the files it created (execept for the `backup-sys-debugger.log` file), then kills the shell to return to the parent shell
# 11. Returns to `net-debugger` shell and run's nano to view the `.log` file (the one named after the option they chose)
# 12. Once the user exits nano, prompt them with the following options:
#      - 1. Get a summary of test results
#            - provide a summary `.log` file (the one named after the option they chose)
#      - 2. Run another test
#            - return user to "Net-Debugger Menu"
#      - 3. Exit `net-debugger` program
#            - runs cleanup file, kills `net-debugger` shell
# 13. Print the following message to the user:
#       - "Thank you for using the Net-Debugger Script, if you have feedback or issues with the script, open a new issue here: https://github.com/PR-CYBR/PR-CYBR-INFRASTRUCTURE-AGENT/issues"
# 14. End script