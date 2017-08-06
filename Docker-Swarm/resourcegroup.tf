
# Configure the Resource Group
resource "azurerm_resource_group" "dev-res-1" {
  name     = "Dev-Res-1"
  location = "${var.region}"

  tags {
    environment = "Dev"
  }
}
