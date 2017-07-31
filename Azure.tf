# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

# Configure the Resource Group
resource "azurerm_resource_group" "dev-res-1" {
  name     = "Dev-Res-1"
  location = "UK South"

  tags {
    environment = "Dev"
  }
}

# Configure the Virtual Network
# work in progress
/*
resource "azurerm_virtual_network" "dev-net-1" {
  name                = "Dev-Net-1"
  resource_group_name = "${azurerm_resource_group.dev-res-1.name}"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.dev-res-1.location}"
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
  }

  subnet {
    name           = "subnet3"
    address_prefix = "10.0.3.0/24"
    security_group = "${azurerm_network_security_group.test.id}"
  }

  tags {
    environment = "Production"
  }
}
*/
