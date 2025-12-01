
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

  subscription_id = "8340c0e6-0f3e-4a79-b0dc-8169e4997589"
  tenant_id       = var.AzureTenantID
  client_id       = var.AzureClientID
  client_secret   = var.AzureClientSecret

}

