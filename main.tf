terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.51.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
  # When you're logged in with `az login`, no extra auth needed.
  # To force a subscription, uncomment:
  # subscription_id = var.subscription_id
}

# Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "monitor" {
  name                = "law-${var.project}-${var.env}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# ----- Infra -----

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project}-${var.env}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_service_plan" "plan" {
  name                = "asp-${var.project}-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = var.appservice_sku # e.g. B1, P1v3, etc.
  tags                = var.tags
}

resource "azurerm_linux_web_app" "app" {
  name                = "app-${var.project}-${var.env}-1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id
  https_only          = true
  tags                = var.tags

  site_config {
    always_on = false

    # Choose a runtime; example: Node 18 LTS
    application_stack {
      node_version = "18-lts"
      # For other stacks, examples:
      # dotnet_version   = "8.0"
      # python_version   = "3.12"
      # php_version      = "8.2"
      # use the one that fits your app
    }
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"       = "0"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "0"
    # add your own settings here
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"]
    ]
  }
}

# Azure Monitor Action Group for email notifications
resource "azurerm_monitor_action_group" "email_alerts" {
  name                = "ag-${var.project}-${var.env}-email"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "EmailAG"

  email_receiver {
    name                    = "AppAdmin"
    email_address           = var.alert_email # Add this variable to variables.tf
    use_common_alert_schema = true
  }
}

# Diagnostic settings to send logs/metrics to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "webapp_diag" {
  name                       = "diag-${azurerm_linux_web_app.app.name}"
  target_resource_id         = azurerm_linux_web_app.app.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.monitor.id

  enabled_log {
    category = "AppServiceAppLogs"
  }
  enabled_log {
    category = "AppServiceAuditLogs"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}

# Alert when the app is down (HTTP 5xx errors)
resource "azurerm_monitor_metric_alert" "app_down" {
  name                = "alert-${azurerm_linux_web_app.app.name}-down"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_linux_web_app.app.id]
  description         = "Web App is down"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 1
  }
  action {
    action_group_id = azurerm_monitor_action_group.email_alerts.id
  }
}

# Alert when the app is restarted
resource "azurerm_monitor_activity_log_alert" "app_restarted" {
  name                = "alert-${azurerm_linux_web_app.app.name}-restarted"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_resource_group.rg.id]
  description         = "Web App was restarted"
  location            = "global"
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Web/sites/restart/action"
  }
  action {
    action_group_id = azurerm_monitor_action_group.email_alerts.id
  }
}

# --------------------------
# Azure Managed Redis (Balanced_B0)
# --------------------------

resource "azurerm_managed_redis" "redis" {
  name                = "redis-${var.project}-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku_name = "Balanced_B0" # Small, cost-effective tier for dev/test or lightweight workloads

  # default_database {
  #   geo_replication_group_name = "defaultGeoGroup-${var.env}"
  # }

  tags = var.tags
}

output "redis_hostname" {
  value = azurerm_managed_redis.redis.hostname
}

# Redis port is typically 6380 for SSL, which is the default for Azure Redis.
output "redis_port" {
  value = 6380
}

output "redis_id" {
  value = azurerm_managed_redis.redis.id
}