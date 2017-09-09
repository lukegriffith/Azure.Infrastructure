// Configuration for Network.
// vnet, subnet and nsg.

resource "azurerm_virtual_network" "dev-vnet" {
  name                = "devvn"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.dev-res-1.name}"
}

// App network

resource "azurerm_subnet" "dev-subnet" {
  name                 = "devsb-app"
  resource_group_name  = "${azurerm_resource_group.dev-res-1.name}"
  virtual_network_name = "${azurerm_virtual_network.dev-vnet.name}"
  address_prefix       = "10.0.2.0/24"
}


// Mgmt network

resource "azurerm_subnet" "dev-subnet-mgmt" {
  name                 = "devsb-mgmt"
  resource_group_name  = "${azurerm_resource_group.dev-res-1.name}"
  virtual_network_name = "${azurerm_virtual_network.dev-vnet.name}"
  address_prefix       = "10.0.3.0/24"
}


// network security groups


resource "azurerm_network_security_group" "dev-nsg-app" {
  name                = "dev-nsg1-app"
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
    source_address_prefix      = "10.0.3.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "winrm"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "10.0.3.0/24"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "RDP-1"
    priority                   = 102
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


resource "azurerm_network_security_group" "dev-nsg-mgmt" {
  name                = "dev-nsg1-mgmt"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.dev-res-1.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  tags {
    environment = "Dev"
  }
}