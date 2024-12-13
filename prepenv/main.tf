

resource "azurerm_resource_group" "RG" {
  for_each = toset(var.TrainingList)
  name     = "rsg-${each.value}"
  location = var.AzureRegion

  tags = {
    layer = "main"
  }
}


resource "azurerm_storage_account" "Statfstate" {
  for_each = toset(var.TrainingList)

  access_tier                       = "Hot"
  account_kind                      = "StorageV2"
  account_replication_type          = "LRS"
  account_tier                      = "Standard"
  allow_nested_items_to_be_public   = true
  allowed_copy_scope                = null
  cross_tenant_replication_enabled  = true
  default_to_oauth_authentication   = false
  edge_zone                         = null
  #enable_https_traffic_only         = true
  infrastructure_encryption_enabled = false
  is_hns_enabled                    = false
  large_file_share_enabled          = null
  location                          = "eastus"
  min_tls_version                   = "TLS1_2"
  name                              = lower(substr(format("%s%s", "sta", replace(each.value, ".", "")), 0, 24))
  nfsv3_enabled                     = false
  public_network_access_enabled     = true
  queue_encryption_key_type         = "Service"
  resource_group_name               = azurerm_resource_group.RG[each.value].name
  sftp_enabled                      = false
  shared_access_key_enabled         = true
  table_encryption_key_type         = "Service"
  tags = {
    ManagedBy = "Terraform"
    Usage     = "Terraform lab backend"
  }
  blob_properties {
    change_feed_enabled           = false
    change_feed_retention_in_days = null
    default_service_version       = null
    last_access_time_enabled      = false
    versioning_enabled            = false
    container_delete_retention_policy {
      days = 7
    }
    delete_retention_policy {
      days = 7
    }
  }
  network_rules {
    bypass                     = ["AzureServices"]
    default_action             = "Allow"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
  queue_properties {
    hour_metrics {
      enabled               = true
      include_apis          = true
      retention_policy_days = 7
      version               = "1.0"
    }
    logging {
      delete                = false
      read                  = false
      retention_policy_days = null
      version               = "1.0"
      write                 = false
    }
    minute_metrics {
      enabled               = false
      include_apis          = false
      retention_policy_days = null
      version               = "1.0"
    }
  }
  share_properties {
    retention_policy {
      days = 7
    }
  }
}

resource "azurerm_resource_group" "RG2" {
  provider = azurerm.trainingroom3
  #count                                 = 3
  for_each = toset(var.TrainingList)
  name     = "rsg-${each.value}-2"
  location = var.AzureRegion

  tags = {
    layer = "lab"
  }
}

resource "azurerm_role_assignment" "rbacrg" {
  for_each             = toset(var.TrainingList)
  scope                = azurerm_resource_group.RG[each.value].id
  role_definition_name = "Contributor"
  principal_id         = "0fc60ab8-b9c9-4ffa-aa0e-7b496947755f"
}

resource "azurerm_role_assignment" "rbacrg2" {
  provider             = azurerm.trainingroom3
  for_each             = toset(var.TrainingList)
  scope                = azurerm_resource_group.RG2[each.value].id
  role_definition_name = "Contributor"
  principal_id         = "0fc60ab8-b9c9-4ffa-aa0e-7b496947755f"
}

