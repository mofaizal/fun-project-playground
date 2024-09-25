variable "RootManagementGroupAzureSPNAppId" {
  type        = string
  description = "Root Management Group Azure Service Principle App Id"
}

variable "RootManagementGroupAzureSPNPwd" {
  type        = string
  description = "Root Management Group Azure  Service Principle Password"
}

variable "AzureTenantId" {
  type        = string
  description = "Azure Tenant Id"
}

variable "primary_location" {
  type        = string
  description = "Sets the location for \"primary\" resources to be created in."
  default     = "southeastasia"
}

variable "secondary_location" {
  type        = string
  description = "Sets the location for \"secondary\" resources to be created in."
  default     = "eastasia"
}

variable "subscription_id_connectivity" {
  type        = string
  description = "Subscription ID to use for \"connectivity\" resources."
  default     = ""
}

variable "subscription_id_identity" {
  type        = string
  description = "Subscription ID to use for \"identity\" resources."
  default     = ""
}

variable "subscription_id_management" {
  type        = string
  description = "Subscription ID to use for \"management\" resources."
  default     = ""
}

variable "connectivity_display_name" {
  type    = string
  default = "Your Root Managment Group Name"
}