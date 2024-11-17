**Assistant-ID**:
- `asst_bYB3rzj39SgrWy3qvuOD75FO`

**Github Repository**:
- Repo: `https://github.com/PR-CYBR/PR-CYBR-INFRASTRUCTURE-AGENT`
- Setup Script (local): `https://github.com/PR-CYBR/PR-CYBR-INFRASTRUCTURE-AGENT/blob/main/scripts/local_setup.sh`
- Setup Script (cloud): `https://github.com/PR-CYBR/PR-CYBR-INFRASTRUCTURE-AGENT/blob/main/.github/workflows/docker-compose.yml`
- Project Board: `https://github.com/orgs/PR-CYBR/projects/11`
- Discussion Board: `https://github.com/PR-CYBR/PR-CYBR-INFRASTRUCTURE-AGENT/discussions`
- Wiki: `https://github.com/PR-CYBR/PR-CYBR-INFRASTRUCTURE-AGENT/wiki`

**Docker Repository**:
- Repo: `https://hub.docker.com/r/prcybr/pr-cybr-infrastructure-agent`
- Pull-Command:
```shell
docker pull prcybr/pr-cybr-infrastructure-agent
```


---


```markdown
# System Instructions for PR-CYBR-INFRASTRUCTURE-AGENT

## Role:
You are the `PR-CYBR-INFRASTRUCTURE-AGENT`, responsible for designing, deploying, and maintaining the infrastructure supporting the PR-CYBR initiative. Your focus is to ensure the scalability, reliability, and resilience of all physical and digital infrastructure required to achieve PR-CYBR’s objectives.

## Core Functions:
1. **Infrastructure Design**:
   - Plan and architect the technical infrastructure required for PR-CYBR systems, including cloud resources, on-premise systems, and network setups.
   - Design redundant and resilient systems to ensure availability during disasters or cyber incidents.
   - Integrate secure and scalable infrastructure components that align with PR-CYBR’s long-term goals.

2. **Deployment and Automation**:
   - Deploy infrastructure as code (IaC) to streamline provisioning and configuration.
   - Automate monitoring, scaling, and failover processes to minimize manual intervention and maximize efficiency.

3. **Network Management**:
   - Establish secure, high-performance networks that connect all PR-CYBR systems, divisions, and external partners.
   - Ensure robust communication channels between divisions (DIVs), barrios (BARs), and sectors (SECs).
   - Monitor and optimize network performance, resolving bottlenecks or vulnerabilities.

4. **Data Center and Cloud Operations**:
   - Manage hybrid infrastructure using both local data centers and cloud providers to meet performance and compliance needs.
   - Optimize resource utilization to maintain cost efficiency without compromising performance.

5. **Security Integration**:
   - Implement foundational security measures, including firewalls, intrusion detection systems, and access control mechanisms.
   - Collaborate with PR-CYBR-SECURITY-AGENT to apply advanced cybersecurity protocols across the infrastructure.

6. **Resilience and Disaster Recovery**:
   - Develop and maintain a disaster recovery plan to ensure the rapid restoration of services during outages or cyberattacks.
   - Establish backup and replication strategies for critical data and services.

7. **Monitoring and Maintenance**:
   - Implement monitoring tools and dashboards to continuously track the health and performance of all infrastructure components.
   - Conduct routine maintenance, updates, and patching to keep systems secure and operational.

8. **Collaboration**:
   - Work with PR-CYBR-BACKEND-AGENT and PR-CYBR-DATA-INTEGRATION-AGENT to ensure seamless integration of infrastructure with backend services and data pipelines.
   - Partner with PR-CYBR-PERFORMANCE-AGENT to identify performance issues and implement solutions.

9. **Resource Allocation**:
   - Manage infrastructure resources effectively to balance workloads, ensuring equitable resource distribution across PR-CYBR divisions.
   - Scale resources dynamically based on user demand and system requirements.

10. **Documentation and Knowledge Sharing**:
    - Provide detailed infrastructure documentation to PR-CYBR-DOCUMENTATION-AGENT for knowledge base inclusion.
    - Document best practices, troubleshooting guides, and deployment steps for future reference.

11. **Sustainability and Cost Optimization**:
    - Design infrastructure solutions that are environmentally sustainable, leveraging energy-efficient systems and practices.
    - Optimize resource usage to reduce costs while maintaining high performance.

12. **Innovation and Future Planning**:
    - Research and adopt emerging technologies to improve infrastructure capabilities.
    - Plan for future scalability to accommodate the growing needs of PR-CYBR.

## Key Directives:
- Prioritize security, resilience, and scalability in all infrastructure decisions.
- Maintain a proactive approach to monitoring, preventing, and addressing infrastructure issues.
- Ensure seamless integration and collaboration with other PR-CYBR agents and systems.

## Interaction Guidelines:
- Collaborate with other agents to understand their infrastructure needs and provide tailored solutions.
- Provide real-time updates on infrastructure status and communicate potential risks or bottlenecks.
- Proactively offer recommendations for infrastructure improvements to support PR-CYBR’s mission.

## Context Awareness:
- Be aware of the unique challenges faced by Puerto Rico, including natural disasters, connectivity issues, and resource limitations.
- Adapt infrastructure solutions to meet the specific needs of divisions, barrios, and sectors.
- Emphasize the importance of accessibility, reliability, and sustainability in infrastructure design.

## Tools and Capabilities:
You are equipped with infrastructure automation tools, cloud management platforms, network monitoring systems, and disaster recovery solutions. Use these to ensure PR-CYBR’s infrastructure remains robust, secure, and scalable.
```

**Directory Structure**:

```shell
PR-CYBR-INFRASTRUCTURE-AGENT/
	.github/
		workflows/
			ci-cd.yml
			docker-compose.yml
			openai-function.yml
	config/
		docker-compose.yml
		secrets.example.yml
		settings.yml
	docs/
		OPORD/
		README.md
	scripts/
		deploy_agent.sh
		local_setup.sh
		provision_agent.sh
	src/
		agent_logic/
			__init__.py
			core_functions.py
		shared/
			__init__.py
			utils.py
	tests/
		test_core_functions.py
	web/
		README.md
		index.html
	.gitignore
	LICENSE
	README.md
	requirements.txt
	setup.py
```

## Agent Core Functionality Overview

```markdown
# PR-CYBR-INFRASTRUCTURE-AGENT Core Functionality Technical Outline

## Introduction

The **PR-CYBR-INFRASTRUCTURE-AGENT** is responsible for managing and orchestrating the underlying infrastructure that supports the PR-CYBR initiative. Its primary functions include provisioning resources, managing network configurations, ensuring high availability, and optimizing resource utilization across all environments (development, testing, staging, and production). The agent ensures that the infrastructure is scalable, secure, and aligned with the needs of various agents within the initiative.
```

```markdown
### Directory Structure

PR-CYBR-INFRASTRUCTURE-AGENT/
├── config/
│   ├── terraform/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── provider.tf
│   ├── ansible/
│   │   ├── playbooks/
│   │   │   ├── deploy.yml
│   │   │   └── configure.yml
│   │   └── inventory/
│   │       └── hosts.ini
│   ├── settings.yml
│   ├── secrets.example.yml
├── scripts/
│   ├── provision_resources.sh
│   ├── configure_network.sh
│   ├── scale_resources.sh
│   └── monitor_infrastructure.sh
├── src/
│   ├── agent_logic/
│   │   ├── __init__.py
│   │   └── core_functions.py
│   ├── resource_management/
│   │   ├── __init__.py
│   │   ├── provisioning.py
│   │   ├── scaling.py
│   │   └── optimization.py
│   ├── network_management/
│   │   ├── __init__.py
│   │   ├── configuration.py
│   │   └── security.py
│   ├── monitoring/
│   │   ├── __init__.py
│   │   ├── infra_monitor.py
│   │   └── alerts.py
│   ├── automation/
│   │   ├── __init__.py
│   │   ├── ansible_runner.py
│   │   └── terraform_runner.py
│   ├── shared/
│   │   ├── __init__.py
│   │   └── utils.py
│   └── interfaces/
│       ├── __init__.py
│       └── inter_agent_comm.py
├── tests/
│   ├── test_core_functions.py
│   ├── test_resource_management.py
│   └── test_network_management.py
└── web/
    ├── static/
    ├── templates/
    └── app.py
```

```markdown
## Key Files and Modules

- **`src/agent_logic/core_functions.py`**: Orchestrates infrastructure operations, including provisioning, configuration, and scaling.
- **`src/resource_management/provisioning.py`**: Handles the provisioning of compute, storage, and networking resources.
- **`src/resource_management/scaling.py`**: Manages scaling operations based on demand.
- **`src/resource_management/optimization.py`**: Optimizes resource utilization and cost efficiency.
- **`src/network_management/configuration.py`**: Configures network settings, including VPCs, subnets, and security groups.
- **`src/network_management/security.py`**: Implements network security measures like firewalls and VPNs.
- **`src/monitoring/infra_monitor.py`**: Monitors the health and performance of infrastructure components.
- **`src/automation/ansible_runner.py`**: Executes Ansible playbooks for configuration management.
- **`src/automation/terraform_runner.py`**: Executes Terraform scripts for infrastructure provisioning.
- **`src/shared/utils.py`**: Contains utility functions for logging, configuration loading, and exception handling.
- **`config/terraform/`**: Contains Terraform scripts for infrastructure as code (IaC).
- **`config/ansible/`**: Contains Ansible playbooks and inventory files for configuration management.
- **`scripts/`**: Shell scripts for automating infrastructure tasks.

## Core Functionalities

### 1. Infrastructure Provisioning (`provisioning.py` and `terraform_runner.py`)

#### Modules and Functions:

- **`provision_resources()`** (`provisioning.py`)
  - Provisions compute (VMs, containers), storage (databases, object storage), and network resources.
  - Inputs: Infrastructure definitions from `config/terraform/` and `settings.yml`.
  - Outputs: Provisioned resources in the cloud environment.

- **`run_terraform_scripts()`** (`terraform_runner.py`)
  - Automates the execution of Terraform scripts.
  - Inputs: Terraform configuration files.
  - Outputs: Applied infrastructure changes.

#### Interaction with Other Agents:

- **Deployment Coordination**: Works with `PR-CYBR-CI-CD-AGENT` to provision infrastructure during deployment pipelines.
- **Security Compliance**: Aligns with `PR-CYBR-SECURITY-AGENT` to ensure infrastructure meets security standards.

### 2. Configuration Management (`ansible_runner.py` and `configuration.py`)

#### Modules and Functions:

- **`configure_resources()`** (`configuration.py`)
  - Configures provisioned resources with necessary software and settings.
  - Inputs: Configuration definitions from `config/ansible/` and `settings.yml`.
  - Outputs: Configured resources ready for use.

- **`run_ansible_playbooks()`** (`ansible_runner.py`)
  - Executes Ansible playbooks for automated configuration.
  - Inputs: Ansible playbooks and inventory files.
  - Outputs: Applied configurations to infrastructure resources.

#### Interaction with Other Agents:

- **Application Deployment**: Prepares infrastructure for applications managed by `PR-CYBR-BACKEND-AGENT` and `PR-CYBR-FRONTEND-AGENT`.
- **Compliance Enforcement**: Ensures configurations adhere to policies set by `PR-CYBR-SECURITY-AGENT`.

### 3. Resource Scaling and Optimization (`scaling.py` and `optimization.py`)

#### Modules and Functions:

- **`auto_scale_resources()`** (`scaling.py`)
  - Adjusts resource allocations based on real-time demand.
  - Inputs: Metrics from `PR-CYBR-PERFORMANCE-AGENT` and predefined scaling policies.
  - Outputs: Scaled resources to match demand.

- **`optimize_resource_utilization()`** (`optimization.py`)
  - Identifies underutilized resources and optimizes costs.
  - Inputs: Resource usage data.
  - Outputs: Recommendations or automated adjustments for cost savings.

#### Interaction with Other Agents:

- **Performance Feedback**: Receives performance data from `PR-CYBR-PERFORMANCE-AGENT` for scaling decisions.
- **Cost Management**: Reports cost optimization metrics to `PR-CYBR-MGMT-AGENT`.

### 4. Network Management and Security (`configuration.py` and `security.py`)

#### Modules and Functions:

- **`configure_network()`** (`configuration.py`)
  - Sets up networking components like VPCs, subnets, and routing tables.
  - Inputs: Network configurations from `settings.yml`.
  - Outputs: Configured network infrastructure.

- **`implement_network_security()`** (`security.py`)
  - Applies security measures such as firewalls, security groups, and VPNs.
  - Inputs: Security policies from `PR-CYBR-SECURITY-AGENT`.
  - Outputs: Secured network environment.

#### Interaction with Other Agents:

- **Security Compliance**: Works closely with `PR-CYBR-SECURITY-AGENT` to enforce network security policies.
- **Connectivity**: Ensures that all agents can communicate securely over the network.

### 5. Infrastructure Monitoring and Alerting (`infra_monitor.py` and `alerts.py`)

#### Modules and Functions:

- **`monitor_infrastructure()`** (`infra_monitor.py`)
  - Continuously monitors the health and performance of infrastructure components.
  - Inputs: Metrics and logs from infrastructure services.
  - Outputs: Monitoring data and health reports.

- **`generate_alerts()`** (`alerts.py`)
  - Sends alerts based on predefined thresholds and anomalies.
  - Inputs: Monitoring data and alerting rules.
  - Outputs: Notifications to relevant agents and teams.

#### Interaction with Other Agents:

- **Incident Response**: Notifies `PR-CYBR-SECURITY-AGENT` and `PR-CYBR-MGMT-AGENT` of critical infrastructure issues.
- **Performance Tuning**: Provides data to `PR-CYBR-PERFORMANCE-AGENT` for optimization efforts.

## Inter-Agent Communication Mechanisms

### Communication Protocols

- **APIs**: Exposes endpoints for resource provisioning and configuration requests from other agents.
- **Message Queues**: Uses systems like RabbitMQ or Kafka for asynchronous communication and event-driven workflows.
- **SSH and Secure Shells**: For secure execution of configuration scripts on infrastructure resources.

### Data Formats

- **JSON and YAML**: Used for configuration files, data exchange, and automation scripts.
- **Terraform and Ansible Formats**: Specific formats for infrastructure as code and configuration management.

### Authentication and Authorization

- **Cloud Provider Credentials**: Securely manages credentials for cloud services (AWS, GCP, Azure).
- **SSH Keys**: For secure access to servers and infrastructure components.
- **Role-Based Access Control (RBAC)**: Implements strict permissions for who can provision and modify infrastructure.

## Interaction with Specific Agents

### PR-CYBR-MGMT-AGENT

- **Resource Allocation**: Receives directives on resource allocation priorities.
- **Reporting**: Provides infrastructure status and cost reports.

### PR-CYBR-CI-CD-AGENT

- **Deployment Pipelines**: Collaborates on provisioning and configuring infrastructure during deployments.
- **Environment Management**: Manages different environments (dev, test, prod) for deployments.

### PR-CYBR-SECURITY-AGENT

- **Security Policies**: Implements network and infrastructure security policies.
- **Incident Management**: Coordinates on security incidents affecting infrastructure.

### PR-CYBR-PERFORMANCE-AGENT

- **Monitoring Data**: Shares infrastructure performance metrics.
- **Scaling Decisions**: Adjusts resources based on performance agent's analyses.

### PR-CYBR-BACKEND-AGENT and PR-CYBR-FRONTEND-AGENT

- **Application Hosting**: Provides the necessary infrastructure for applications to run.
- **Configuration Requirements**: Applies specific configurations required by these agents.

## Technical Workflows

### Infrastructure Provisioning Workflow

1. **Initiation**: A request for new resources is received (e.g., scaling up for increased load).
2. **Terraform Execution**: `run_terraform_scripts()` executes Terraform scripts to provision resources.
3. **Configuration**: `run_ansible_playbooks()` applies configurations to the new resources.
4. **Verification**: Confirms that resources are operational and correctly configured.
5. **Notification**: Notifies relevant agents that resources are ready.

### Auto-Scaling Workflow

1. **Monitoring**: `monitor_infrastructure()` collects performance metrics.
2. **Analysis**: `auto_scale_resources()` evaluates whether scaling is needed.
3. **Scaling Action**: Provisions or decommissions resources accordingly.
4. **Update Configuration**: Ensures new resources are configured appropriately.
5. **Feedback Loop**: Updates `PR-CYBR-PERFORMANCE-AGENT` and `PR-CYBR-MGMT-AGENT` on scaling actions.

### Network Configuration Workflow

1. **Policy Retrieval**: Retrieves network configurations and security policies.
2. **Network Setup**: `configure_network()` sets up network components.
3. **Security Implementation**: `implement_network_security()` applies security measures.
4. **Testing**: Validates network connectivity and security settings.
5. **Deployment**: Makes the network available for use by other agents.

## Error Handling and Logging

- **Exception Handling**: Implements try-except blocks to catch errors during provisioning and configuration.
- **Logging**: Uses centralized logging systems to record all infrastructure changes and events.
- **Alerting**: `generate_alerts()` sends immediate notifications for critical failures or security breaches.
- **Rollback Mechanisms**: Supports rolling back to previous infrastructure states in case of failures.

## Security Considerations

- **Infrastructure Hardening**: Applies best practices to secure servers, networks, and services.
- **Access Control**: Enforces least privilege principles for access to infrastructure components.
- **Encryption**: Utilizes encryption for data in transit and at rest.
- **Compliance**: Ensures infrastructure complies with regulatory requirements (e.g., HIPAA, GDPR).
- **Regular Audits**: Collaborates with `PR-CYBR-SECURITY-AGENT` to perform security audits.

## Deployment and Scaling

- **Infrastructure as Code (IaC)**: Uses Terraform and Ansible for automated, repeatable deployments.
- **Scalability**: Designed to scale horizontally and vertically based on demand.
- **Container Orchestration**: Supports Kubernetes and Docker Swarm for containerized workloads.
- **High Availability**: Implements redundancy and failover strategies to minimize downtime.
- **Cloud Agnostic**: Capable of operating across multiple cloud providers for flexibility.

## Conclusion

The **PR-CYBR-INFRASTRUCTURE-AGENT** is essential for providing a robust, secure, and scalable foundation for the PR-CYBR initiative. By automating infrastructure provisioning, configuration, and scaling, it ensures that all agents have the necessary resources to perform their functions effectively. Its close collaboration with other agents, adherence to security standards, and utilization of infrastructure as code principles make it a critical component in achieving the initiative's goals of resilience and efficiency.
```


---

## OpenAI Functions

## Function List for PR-CYBR-INFRASTRUCTURE-AGENT

```markdown
## Function List for PR-CYBR-INFRASTRUCTURE-AGENT

1. **infrastructure_design**: Assists in planning and architecting technical infrastructure for PR-CYBR systems, taking into account scalability, reliability, and security.
2. **deploy_infrastructure_iac**: Automates the deployment of infrastructure as code (IaC) for streamlined provisioning and configuration.
3. **monitor_network_performance**: Monitors and optimizes network performance, providing insights into potential bottlenecks or vulnerabilities.
4. **disaster_recovery_plan**: Develops and maintains a comprehensive disaster recovery plan to ensure rapid restoration of services during outages or cyberattacks.
5. **resource_allocation_management**: Manages and allocates infrastructure resources effectively, dynamically scaling based on demand and system requirements.
6. **security_integrations**: Implements foundational security measures, integrating with advanced cybersecurity protocols to protect infrastructure.
7. **environmental_sustainability**: Designs infrastructure solutions that prioritize environmental sustainability, utilizing energy-efficient practices and systems.
8. **real_time_monitoring**: Implements monitoring tools and dashboards for real-time tracking of health and performance across all infrastructure components.
9. **collaborate_with_agents**: Facilitates collaboration with other PR-CYBR agents to align infrastructure with backend services and data pipelines.
10. **future_planning_infrastructure**: Researches and adopts emerging technologies to improve infrastructure capabilities and plans for future scalability.
```