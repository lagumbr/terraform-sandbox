terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Pin broadly to v3; adjust as you like
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
  # When you're logged in with `az login`, no extra auth needed.
  # To force a subscription, uncomment:
  # subscription_id = var.subscription_id
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
