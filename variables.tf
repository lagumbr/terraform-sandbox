variable "alert_email" {
  description = "Email address to receive Azure Monitor alerts."
  type        = string
}

variable "subscription_id" {
  description = "Optional: force a specific subscription (otherwise uses Azure CLI logged-in context)"
  type        = string
  default     = "338831ea-da6f-42c7-98ad-8316e341a53c"
}

variable "project" {
  type        = string
  default     = "ron-test-project"
  description = "Short project name"
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Environment name"
}

variable "location" {
  type        = string
  # Close to NZ; pick what you prefer
  default     = "Australia East"
  description = "Azure region"
}

variable "appservice_sku" {
  type        = string
  # B1 is a low-cost paid plan. F1 (Free) is very limited and not always available for Linux.
  default     = "F1"
  description = "App Service Plan SKU (e.g., B1, S1, P1v3)"
}

variable "tags" {
  type = map(string)
  default = {
    "owner" = "terraform"
  }
}
