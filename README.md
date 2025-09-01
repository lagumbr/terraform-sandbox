# How to get your Azure Subscription ID

Run this command in your terminal:

```pwsh
az account show --query id --output tsv
```

This will print your current Azure subscription ID, which you can use in your Terraform configuration.
# GitHub Actions Deployment

This project uses GitHub Actions to deploy the Node.js app to Azure App Service automatically:

1. On every push to the configured branch, GitHub Actions runs the workflow in `.github/workflows/`.
2. The workflow checks out your code, installs dependencies, builds (if needed), and deploys to Azure using the `azure/webapps-deploy` action.
3. The deployment uses the publish profile secret (`AZUREAPPSERVICE_PUBLISHPROFILE`) for authentication.
4. To deploy the app in the `src` folder, set `package: src` in the workflow file.


**The set up:**
1. In Azure Portal, go to your App Service and open Deployment Center.
2. Connect your App Service to your GitHub repository and branch.
3. Azure automatically creates the workflow YAML file in your repo.
4. Now, every commit and push to the configured branch will automatically deploy changes to Azure App Service.

Refer to the workflow file for details and update as needed for your app structure.
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
