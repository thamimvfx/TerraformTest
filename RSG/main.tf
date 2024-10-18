#Resource Group Creation

provider "azurerm" {
  features {}
  subscription_id = "de0065f2-2031-47e7-9704-2cc8de008e62"
}

resource "azurerm_resource_group" "test" {
  name = "cbtf-testRG"
  location = "North Europe"
}

resource "azurerm_resource_group" "staging" {
  name = "cbtf-stagingRG"
  location = "North Europe"
}

resource "azurerm_resource_group" "production" {
  name = "cbtf-productionRG"
  location = "North Europe"
}