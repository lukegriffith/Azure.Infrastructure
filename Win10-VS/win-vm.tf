// Configuration for Win-VM's.
// Network, IP and VM based resources.


resource "azurerm_public_ip" "dev-public-ip" {
  name                         = "vs-public-ip"
  location                     = "${var.region}"
  resource_group_name          = "${azurerm_resource_group.dev-res-1.name}"
  public_ip_address_allocation = "static"

  tags {
    environment = "vs"
  }
}


resource "azurerm_network_interface" "dev-int" {
  name                = "vsint"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.dev-res-1.name}"
  network_security_group_id = "${azurerm_network_security_group.dev-nsg-app.id}"

  ip_configuration {
    name                          = "vs-int-ip"
    subnet_id                     = "${azurerm_subnet.dev-subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = "${element(azurerm_public_ip.dev-public-ip.*.id, count.index)}" 
  }
}

resource "azurerm_virtual_machine" "dev-vm" {
  

  name                  = "vs-vm"
  location              = "${var.region}"
  resource_group_name   = "${azurerm_resource_group.dev-res-1.name}"
  network_interface_ids = ["${azurerm_network_interface.dev-int.id}"]
  vm_size               = "Standard_D4_v2"
  storage_image_reference {
    publisher = "MicrosoftVisualStudio"
    offer= "VisualStudio"
    sku = "VS-2017-Ent-Win10-N"
    version = "latest"
  }

  storage_os_disk {
    name              = "vs_osdisk_vm"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "vs_datadisk_vm"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "1023"
  }

  os_profile {
    computer_name  = "vs-dev"
    admin_username = "${var.os_username}"
    admin_password = "${var.os_password}"
  }

  tags {
    environment = "vs"
  }
}

