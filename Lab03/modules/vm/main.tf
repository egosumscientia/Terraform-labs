resource "azurerm_network_interface" "nic" {
    name                = "${var.vm_name}-nic"
    location            = var.location
    resource_group_name = var.resource_group_name

    ip_configuration {
        name                          = "internal"
        subnet_id                     = var.subnet_id
        private_ip_address_allocation = "Dynamic"
    }

    tags = var.tags
}

resource "azurerm_linux_virtual_machine" "vm" {
    name                  = var.vm_name
    resource_group_name   = var.resource_group_name
    location              = var.location
    size                  = var.vm_size
    admin_username        = var.admin_username
    network_interface_ids = [azurerm_network_interface.nic.id]

    admin_ssh_key {
        username   = var.admin_username
        public_key = file("~/.ssh/id_rsa.pub")
    }

    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    }

    source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
    }

    tags = var.tags
}