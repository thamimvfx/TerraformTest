#VM Creation with NSG + Rules
provider "azurerm" {
  features {}
  subscription_id = "de0065f2-2031-47e7-9704-2cc8de008e62"
}

resource "azurerm_network_interface" "test_vm_nic" {
  count               = 2
  name                = "test-vm-nic-${count.index + 1}"
  location            = "North Europe"
  resource_group_name = "cbtf-testRG"

  ip_configuration {
    name                          = "test-vm-ip-${count.index + 1}"
    subnet_id                     = "/subscriptions/de0065f2-2031-47e7-9704-2cc8de008e62/resourceGroups/cbtf-testRG/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface_security_group_association" "test-sec-asso" {
  count                    = 2
  network_interface_id     = azurerm_network_interface.test_vm_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.test_nsg.id
}
resource "azurerm_public_ip" "test_vm_ip" {
  count               = 2
  name                = "test-vm-ip-${count.index + 1}"
  location            = "North Europe"
  resource_group_name = "cbtf-testRG"
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "test_nsg" {
  name                = "test-nsg"
  location            = "North Europe"
  resource_group_name = "cbtf-testRG"

  security_rule {
    name                       = "AllowSSH"
    priority                   = 125
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowOutboundDNS"
    priority                   = 150
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_ranges    = ["53"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowOutboundHTTP"
    priority                   = 175
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowOutboundHTTPS"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_machine" "test_vm" {
  count                 = 2
  name                  = "test-vm-${count.index + 1}"
  location              = "North Europe"
  resource_group_name   = "cbtf-testRG"
  network_interface_ids = [azurerm_network_interface.test_vm_nic[count.index].id]
  vm_size               = "Standard_B1s"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "test-vm-osdisk-${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  os_profile {
    computer_name  = "testvm${count.index + 1}"
    admin_username = "azureuser"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_recovery_services_vault" "recovery_vault" {
  name = "test-recovery-vault"
  resource_group_name = "cbtf-testRG"
  location = "north europe"
  sku = "Standard"
}

resource "azurerm_backup_policy_vm" "vm_backup" {
  name                = "vm-backup-policy-test"
  resource_group_name = "cbtf-testRG"
  recovery_vault_name = azurerm_recovery_services_vault.recovery_vault.name

  retention_monthly {
    count = 12
    weeks = ["First"]
    weekdays = ["Sunday"]
  }

  backup {
    frequency = "Daily"
    time      = "20:00"
  }
  retention_daily {
    count = 7
  }
}

resource "azurerm_backup_protected_vm" "test_vm_protected" {
  count           = 2
  recovery_vault_name = "test-recovery-vault"
  resource_group_name = "cbtf-testRG"
  backup_policy_id = azurerm_backup_policy_vm.vm_backup.id
  source_vm_id     = azurerm_virtual_machine.test_vm[count.index].id
}
