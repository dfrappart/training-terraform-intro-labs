

variable "vnet_to_create" {
  type = map(object({
    address_space = optional(string, "172.16.0.0/24")
    location      = optional(string, "francecentral")
    subnets = optional(map(object({
      subnet_address_prefixes = list(string)
      subnet_name             = string

    })), {})
  }))
  description = "List of virtual network to create"
}

variable "location" {
  type        = string
  description = "The region for the Azure resource"
  default     = "francecentral"
}

##############################################################
#Variable declaration for provider

variable "AzureSubscriptionID" {
  type        = string
  description = "The subscription id for the authentication in the provider"
}

variable "AzureClientID" {
  type        = string
  description = "The application Id, taken from Azure AD app registration"
}


variable "AzureClientSecret" {
  type        = string
  description = "The Application secret"

}

variable "AzureTenantID" {
  type        = string
  description = "The Azure AD tenant ID"
}


variable "AzureADClientSecret" {
  type        = string
  description = "The AAD Application secret"

}

variable "AzureADClientID" {
  type        = string
  description = "The AAD Client ID"
}

##############################################################
# Variable for vnet

variable "hub_subnets" {
  type = map(object({
    subnet_address_prefixes = list(string)
    subnet_name             = string

  }))
  description = "List of subnets to create in the hub virtual network"
  default     = {}
}