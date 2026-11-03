
terraform {
  required_version = "~> 1.13.0"

  backend "azurerm" {}

  required_providers {
    azurerm = "~> 4.0.0"

  }

}
