# Public IP for Azure Bastion
resource "azurerm_public_ip" "bastion" {
  name                = "${var.prefix}-bastion-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Azure Bastion Host
resource "azurerm_bastion_host" "main" {
  name                = "${var.prefix}-bastion"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Basic"
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}