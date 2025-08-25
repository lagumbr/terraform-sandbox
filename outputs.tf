output "resource_group" {
  value = azurerm_resource_group.rg.name
}

output "app_service_plan" {
  value = azurerm_service_plan.plan.name
}

output "app_name" {
  value = azurerm_linux_web_app.app.name
}

output "app_url" {
  # Default hostname created by App Service
  value = "https://${azurerm_linux_web_app.app.default_hostname}"
}
