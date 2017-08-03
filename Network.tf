
resource "azurerm_virtual_network" "dev-vnet" {
  name                = "devvn"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.dev-res-1.name}"
}

resource "azurerm_subnet" "dev-subnet" {
  name                 = "devsb"
  resource_group_name  = "${azurerm_resource_group.dev-res-1.name}"
  virtual_network_name = "${azurerm_virtual_network.dev-vnet.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "dev-public-ip" {
  name                         = "dev-public-ip"
  location                     = "${var.region}"
  resource_group_name          = "${azurerm_resource_group.dev-res-1.name}"
  public_ip_address_allocation = "static"

  tags {
    environment = "Dev"
  }
}


resource "azurerm_network_security_group" "dev-nsg" {
  name                = "dev-nsg1"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.dev-res-1.name}"

  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    environment = "Dev"
  }
}
