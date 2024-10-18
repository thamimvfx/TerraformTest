#Virtual Network + Subnet Creation
provider "azurerm" {
  features {}
  subscription_id = "de0065f2-2031-47e7-9704-2cc8de008e62"
}

resource "azurerm_virtual_network" "testVnet" {
  name = "test-vnet"
  address_space = ["10.0.0.0/16"]
  location = "North Europe"
  resource_group_name = "cbtf-testRG"

  #Subnet
  subnet {
    name = "test-subnet"
    address_prefixes = ["10.0.1.0/24"]
  }
}