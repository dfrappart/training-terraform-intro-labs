

resource "azurerm_virtual_network" "feature_vnet" {
  for_each = var.vnet_to_create

  name                = each.key
  address_space       = [each.value.address_space]
  location            = each.value.location
  resource_group_name = data.azurerm_resource_group.feature_rg.name



  provider = azurerm.trainingroom3
}


resource "azurerm_subnet" "feature_subnets" {
  for_each = local.SubnetsMap

  name                 = each.value.subnet_name
  resource_group_name  = data.azurerm_resource_group.feature_rg.name
  virtual_network_name = each.value.vnet_key
  address_prefixes     = each.value.subnet_address_prefixes
  provider             = azurerm.trainingroom3
}


resource "azurerm_virtual_network" "main_vnet" {
  name                = "hub"
  address_space       = ["10.0.0.0/24"]
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main_rg.name
}

resource "azurerm_subnet" "hub_subnets" {

  for_each             = var.hub_subnets
  name                 = each.value.subnet_name
  resource_group_name  = data.azurerm_resource_group.main_rg.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = each.value.subnet_address_prefixes
}

resource "azurerm_virtual_network_peering" "peer-main-to-feature" {
  for_each                  = var.vnet_to_create
  name                      = "peer-main-to-${azurerm_virtual_network.feature_vnet[each.key].name}"
  resource_group_name       = data.azurerm_resource_group.main_rg.name
  virtual_network_name      = azurerm_virtual_network.main_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.feature_vnet[each.key].id
}

resource "azurerm_virtual_network_peering" "peer-feature-to-main" {
  for_each                  = var.vnet_to_create
  name                      = format("peer-%s-to-main", azurerm_virtual_network.feature_vnet[each.key].name)
  resource_group_name       = data.azurerm_resource_group.feature_rg.name
  virtual_network_name      = azurerm_virtual_network.feature_vnet[each.key].name
  remote_virtual_network_id = azurerm_virtual_network.main_vnet.id
  provider                  = azurerm.trainingroom3
}
