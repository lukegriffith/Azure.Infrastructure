// Configuration for Win-VM's.
// Network, IP and VM based resources.


resource "azurerm_public_ip" "dev-public-ip" {
  count = "${var.win_srv_count}"
  name                         = "dev-public-ip-${count.index}"
  location                     = "${var.region}"
  resource_group_name          = "${azurerm_resource_group.dev-res-1.name}"
  public_ip_address_allocation = "static"

  tags {
    environment = "Dev"
  }
}


resource "azurerm_network_interface" "dev-int" {
  count = "${var.win_srv_count}"
  name                = "devint${count.index}"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.dev-res-1.name}"
  network_security_group_id = "${azurerm_network_security_group.dev-nsg-app.id}"

  ip_configuration {
    name                          = "dev-int-${count.index}-ip"
    subnet_id                     = "${azurerm_subnet.dev-subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = "${element(azurerm_public_ip.dev-public-ip.*.id, count.index)}" 
  }
}

resource "azurerm_virtual_machine" "dev-vm" {
  
  count = "${var.win_srv_count}"

  name                  = "win-vm-${count.index}"
  location              = "${var.region}"
  resource_group_name   = "${azurerm_resource_group.dev-res-1.name}"
  network_interface_ids = ["${element(azurerm_network_interface.dev-int.*.id, count.index)}"]
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
    name              = "osdisk_vm_${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "datadisk_vm_${count.index}"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "1023"
  }

  os_profile {
    computer_name  = "win-${count.index}"
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

