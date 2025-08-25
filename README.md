# Terraform Azure Web App Sandbox

This project provisions an Azure Linux Web App with monitoring and alerting using Terraform.

## Features
- Resource Group, Service Plan, and Linux Web App
- Log Analytics Workspace for diagnostics
- Azure Monitor Action Group for email alerts
- Diagnostic settings for logs and metrics
- Alerts for app downtime and restarts

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) >= 1.6
- Azure CLI (`az login` required)
- An Azure subscription

## Setup
1. Clone this repository.
2. Set your variables in `terraform.tfvars`:
   ```hcl
   alert_email = "your@email.com"
   log_analytics_workspace_id = "<resource-id>" # Or use the workspace created by this project
   project = "your-project-name"
   env = "dev"
   location = "Australia East"
   appservice_sku = "B1"
   tags = {
     owner = "terraform"
   }
   ```
3. Execute Terraform steps:
   ```pwsh
   terraform init          # downloads providers
   terraform validate      # sanity check
   terraform plan -out tf.plan
   terraform apply "tf.plan"
   ```

## Customizing Email Alerts
To send alerts to multiple emails, add more `email_receiver` blocks in `main.tf` under the `azurerm_monitor_action_group` resource.

## Troubleshooting
- Ensure your Azure credentials are set with `az login`.
- If you see provider deprecation warnings, update your resource blocks as recommended.

## Clean Up
To remove all resources:
```pwsh
terraform destroy
```

## License
MIT
