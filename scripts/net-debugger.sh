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
