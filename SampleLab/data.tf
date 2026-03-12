
data "azurerm_resource_group" "feature_rg" {
  name = "rsg-davidf-2"

  provider = azurerm.trainingroom3
}

data "azurerm_resource_group" "main_rg" {
  name = "rsg-davidf"
}