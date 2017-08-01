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

/*



*/

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

resource "azurerm_network_interface" "dev-int-01" {
  name                = "devint01"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.dev-res-1.name}"

  ip_configuration {
    name                          = "dev-int-01-ip"
    subnet_id                     = "${azurerm_subnet.dev-subnet.id}"
    private_ip_address_allocation = "dynamic"
  }
}


/*
  GOT TO HERE. CONTINUE.

*/


resource "azurerm_managed_disk" "test" {
  name                 = "datadisk_existing"
  location             = "${var.region}"
  resource_group_name  = "${azurerm_resource_group.dev-res-1.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

resource "azurerm_virtual_machine" "test" {
  name                  = "acctvm"
  location              = "${var.region}"
  resource_group_name   = "${azurerm_resource_group.dev-res-1.name}"
  network_interface_ids = ["${azurerm_network_interface.test.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "14.04.2-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "datadisk_new"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "1023"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.test.name}"
    managed_disk_id = "${azurerm_managed_disk.test.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.test.disk_size_gb}"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "staging"
  }
}