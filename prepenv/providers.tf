
provider "azurerm" {


  #skip_provider_registration = true
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  
  }

  subscription_id = var.AzureSubscriptionID
  tenant_id       = var.AzureTenantID
  client_id       = var.AzureClientID
  client_secret   = var.AzureClientSecret

}

provider "azurerm" {


  #skip_provider_registration = true
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  alias = "trainingroom3"

  subscription_id = "8d2a1f75-7232-45f5-8b46-a0e16f40c8d8"
  tenant_id       = var.AzureTenantID
  client_id       = var.AzureClientID
  client_secret   = var.AzureClientSecret

}

