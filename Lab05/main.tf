terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~> 3.0"
        }
    }
}

provider "azurerm" {
    features {}
    subscription_id = "foobarsuid"
    tenant_id       = "foobarteid"
}

resource "azurerm_resource_group" "vm_rg" {
    name     = "vm-resources-lab"
    location = "eastus"
}

resource "azurerm_virtual_network" "vm_vnet" {
    name                = "vm-network"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.vm_rg.location
    resource_group_name = azurerm_resource_group.vm_rg.name
}

resource "azurerm_subnet" "vm_subnet" {
    name                 = "internal"
    resource_group_name  = azurerm_resource_group.vm_rg.name
    virtual_network_name = azurerm_virtual_network.vm_vnet.name
    address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "vm_nsg" {
    name                = "vm-nsg"
    location            = azurerm_resource_group.vm_rg.location
    resource_group_name = azurerm_resource_group.vm_rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_public_ip" "vm_ip" {
    name                = "vm-public-ip"
    resource_group_name = azurerm_resource_group.vm_rg.name
    location            = azurerm_resource_group.vm_rg.location
    allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "vm_nic" {
    name                = "vm-nic"
    location            = azurerm_resource_group.vm_rg.location
    resource_group_name = azurerm_resource_group.vm_rg.name

    ip_configuration {
            name                          = "internal"
            subnet_id                     = azurerm_subnet.vm_subnet.id
            private_ip_address_allocation = "Dynamic"
            public_ip_address_id          = azurerm_public_ip.vm_ip.id
        }
    }

resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.vm_nic.id
    network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

resource "azurerm_linux_virtual_machine" "main" {
    name                            = "lab-vm"
    resource_group_name             = azurerm_resource_group.vm_rg.name
    location                        = azurerm_resource_group.vm_rg.location
    size                            = "Standard_F2"
    admin_username                  = "adminuser"
    disable_password_authentication = true
    network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
]

admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
}

os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
}

source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }
}