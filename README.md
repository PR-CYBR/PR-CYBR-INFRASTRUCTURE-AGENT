<!--
Updates that need to be made:
1. 
-->

# PR-CYBR-INFRASTRUCTURE-AGENT

## Overview

The **PR-CYBR-INFRASTRUCTURE-AGENT** focuses on automating, managing, and maintaining the underlying infrastructure that supports the PR-CYBR ecosystem. It ensures high availability, scalability, and reliability of cloud and on-premises resources while adhering to security best practices.

## Key Features

- **Cloud Infrastructure Automation**: Deploys and manages cloud resources via Infrastructure as Code (IaC).
- **Monitoring and Alerting**: Implements observability tools to monitor resource health and performance.
- **Scalability Management**: Optimizes resource allocation for scaling based on usage patterns.
- **Disaster Recovery**: Automates backup and recovery processes to ensure data resilience.
- **Security Compliance**: Integrates security standards into infrastructure configurations.

## Getting Started

### Prerequisites

- **Git**: For cloning the repository.
- **Terraform**: Required for infrastructure provisioning.
- **Ansible**: For configuration management.
- **Docker**: Required for containerization and deployment.
- **Access to GitHub Actions**: For automated workflows.

### Local Setup

To set up the `PR-CYBR-INFRASTRUCTURE-AGENT` locally on your machine:

1. **Clone the Repository**

```bash
git clone https://github.com/PR-CYBR/PR-CYBR-INFRASTRUCTURE-AGENT.git
cd PR-CYBR-INFRASTRUCTURE-AGENT
```

2. **Run Local Setup Script**

```bash
./scripts/local_setup.sh
```
_This script will install necessary dependencies and set up the local environment._

3. **Provision the Agent**

```bash
./scripts/provision_agent.sh
```
_This script initializes Terraform and Ansible configurations for local development._

### Cloud Deployment

To deploy the agent using the unified Terraform Cloud workflow:

1. **Configure Repository Secrets & Variables**

   - Navigate to `Settings` > `Secrets and variables` > `Actions` in your GitHub repository.
   - Populate the following names to mirror the A-04 Terraform Cloud workspace schema:
     - Secrets: `TFC_TOKEN`, `AGENT_ACTIONS`, `NOTION_TOKEN`, `PR_CYBR_DOCKER_PASS`, `GLOBAL_TAILSCALE_AUTHKEY`, `GLOBAL_ZEROTIER_NETWORK_ID`
     - Variables: `DOCKERHUB_USERNAME`, `GLOBAL_DOMAIN`, `GLOBAL_ELASTIC_URI`, `NOTION_PAGE_ID`

2. **Deploy Using GitHub Actions**

   - Terraform automation runs through `.github/workflows/tfc-sync.yml`, which executes all Terraform commands from `./infra`.
   - Build and publishing automation is handled by `.github/workflows/docker-hub-update.yml` using the same secret names listed above.

3. **Manual Terraform Operations**

   - To run Terraform locally, work from the `infra/` directory:

```bash
cd infra
terraform init
terraform plan -var-file="variables.tfvars"
```

   - Update `infra/variables.tfvars` with local-safe values if you need to run plans outside of Terraform Cloud.

## Integration

The `PR-CYBR-INFRASTRUCTURE-AGENT` integrates with other PR-CYBR agents to provide a robust and scalable infrastructure foundation. It collaborates with:

- **PR-CYBR-CI-CD-AGENT**: Automates infrastructure provisioning and configuration during deployments.
- **PR-CYBR-SECURITY-AGENT**: Ensures that infrastructure complies with security policies and standards.
- **PR-CYBR-PERFORMANCE-AGENT**: Adjusts resource allocations based on performance metrics and optimization recommendations.
- **PR-CYBR-MGMT-AGENT**: Provides infrastructure status and reports for management oversight.

## Usage

- **Development**

  - Initialize Terraform and Ansible configurations:

```bash
terraform init
ansible-galaxy install -r requirements.yml
 ```

- Plan and apply infrastructure changes locally:

```bash
terraform plan
terraform apply
```

- **Testing**

  - Run infrastructure tests:

```bash
terraform validate
ansible-playbook --check playbooks/deploy.yml
```

- **Building for Production**

  - Deploy infrastructure to the production environment:

```bash
terraform workspace select production
terraform apply
ansible-playbook playbooks/deploy.yml -i inventory/production
```

## License

This project is licensed under the **MIT License**. See the [`LICENSE`](LICENSE) file for details.

---

For more information, refer to the [Terraform Documentation](https://www.terraform.io/docs/index.html), [Ansible Documentation](https://docs.ansible.com/ansible/latest/index.html), or contact the PR-CYBR team.
