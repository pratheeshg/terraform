resource "azurerm_subnet" "hybris" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "10.0.3.0/24"
}

resource "azurerm_network_interface" "hybris" {
  name                      = "hybris-nic"
  location                  = azurerm_resource_group.main.location
  resource_group_name       = azurerm_resource_group.main.name
  network_security_group_id = azurerm_network_security_group.nsg_hybris.id

  ip_configuration {
    name                          = "hybrisconfiguration"
    subnet_id                     = azurerm_subnet.hybris.id
    private_ip_address_allocation = "Dynamic"
  #  private_ip_address            = "10.0.3.5"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_virtual_machine" "hybris" {
  name                  = "${var.prefix}-hybrisvm"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.hybris.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.6"
    version   = "latest"
  }
  storage_os_disk {
    name              = "MyNginx"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "AZR-Hybris01"
    admin_username = "lmsone"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/lmsone/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }
  tags = {
    environment = "staging"
  }
}
