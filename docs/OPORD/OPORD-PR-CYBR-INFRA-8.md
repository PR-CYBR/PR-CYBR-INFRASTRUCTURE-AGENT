# OPORD-PR-CYBR-INFRA-8

## 1. SITUATION
The operational environment requires continuous improvement of the infrastructure to support PR-CYBR's initiatives. The focus is on enhancing connectivity, ensuring resource allocation, and maximizing service availability.

## 2. MISSION
The PR-CYBR-INFRASTRUCTURE-AGENT is tasked with updating the current system, installing necessary tools, and setting up the server as per the details provided in the following execution plan.

## 3. EXECUTION

### 3.1. Objectives
- Ensure the infrastructure is current and meets operational needs.
- Facilitate user setup through clear, interactive prompts for server configuration.

### 3.2. Tasks
1. **Update Current System**: Execute system updates to ensure all software is current.
2. **Install Inspircd**: Utilize Docker to install Inspircd and required dependencies:
   - Reference: [Inspircd GitHub](https://github.com/inspircd/inspircd)
3. **Prompt for User Details**: 
   - Prompt the user for:
     - Server Name
     - IP Address (Choose between Public IP or Zerotier IP)
4. **Install Irssi**: Install Irssi for server connectivity and run a connection test to confirm successful setup.
5. **Automated Script Execution**: Create a setup script that seamlessly configures the server as specified without user intervention post-initial input.
6. **Docker Configuration**: Configure Docker for:
   - Inspircd Server
   - A reverse proxy using nginx for Zerotier IP setup.

### 3.3. Coordinating Instructions
- Ensure seamless communication among agents throughout execution.
- Maintain logs for all activities to facilitate reporting and future troubleshooting.
  
## 4. ADMINISTRATION AND LOGISTICS
- Ensure all installations utilize the latest stable releases.
- Document the installation processes for future reference.

## 5. COMMAND AND SIGNAL
All communications regarding the execution of this OPORD should be directed to the Lead Agent of the PR-CYBR initiative.

---

End of OPORD.
