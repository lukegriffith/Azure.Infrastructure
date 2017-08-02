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
  location = "${var.region}"

  tags {
    environment = "Dev"
  }
}

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

resource "azurerm_network_interface" "dev-int-01" {
  name                = "devint01"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.dev-res-1.name}"
  network_security_group_id = "${azurerm_network_security_group.dev-nsg.id}"

  ip_configuration {
    name                          = "dev-int-01-ip"
    subnet_id                     = "${azurerm_subnet.dev-subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = "${azurerm_public_ip.dev-public-ip.id}"
  }
}

resource "azurerm_managed_disk" "dev-disk-A-1" {
  name                 = "datadisk_A_1"
  location             = "${var.region}"
  resource_group_name  = "${azurerm_resource_group.dev-res-1.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"
}




resource "azurerm_virtual_machine" "dev-vm-A" {
  name                  = "dev-vm-A"
  location              = "${var.region}"
  resource_group_name   = "${azurerm_resource_group.dev-res-1.name}"
  network_interface_ids = ["${azurerm_network_interface.dev-int-01.id}"]
  vm_size               = "Standard_DS1_v2"

/*
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "14.04.2-LTS"
    version   = "latest"
  }
*/
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer= "WindowsServer"
    sku = "2016-Datacenter-with-Containers"
    version = "latest"
  }

  storage_os_disk {
    name              = "osdisk_vm_A"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "datadisk_vm_A"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "1023"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.dev-disk-A-1.name}"
    managed_disk_id = "${azurerm_managed_disk.dev-disk-A-1.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.dev-disk-A-1.disk_size_gb}"
  }

  os_profile {
    computer_name  = "lg-dev-1"
    admin_username = "${var.os_username}"
    admin_password = "${var.os_password}"
  }

/*
  os_profile_linux_config {
    disable_password_authentication = false
  }
*/
  tags {
    environment = "Dev"
  }
}

