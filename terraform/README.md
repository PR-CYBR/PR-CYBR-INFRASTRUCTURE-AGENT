# Terraform Configuration Placeholder

This directory stores the Terraform configuration that Terraform Cloud consumes. The Terraform Cloud workflow bridge GitHub Action uploads the contents of this directory to the configured Terraform Cloud workspace whenever a plan or apply run is triggered.

- Place all `.tf`, `.tf.json`, and supporting files in this directory.
- Keep sensitive values in Terraform Cloud workspace variables rather than committing them here.
- If you prefer an alternate layout, define a repository variable named `TF_CONFIG_DIRECTORY` that points to the relative path containing your Terraform configuration.
