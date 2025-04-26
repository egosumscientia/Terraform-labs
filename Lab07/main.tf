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
    subscription_id = "xyz"
    tenant_id       = "abc"
}

# =============================
#   Recursos de Red y Seguridad
# =============================

resource "azurerm_resource_group" "main" {
    name     = "lab-net-rg"
    location = var.location
}

resource "azurerm_virtual_network" "vnet" {
    name                = "lab-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "subnet1" {
    name                 = "subnet-public"
    resource_group_name  = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
    name                = "lab-nsg"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_rule" "allow_http" {
    name                        = "allow-http"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "80"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.main.name
    network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "allow_ssh" {
    name                        = "allow-ssh"
    priority                    = 110
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.main.name
    network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
    subnet_id                 = azurerm_subnet.subnet1.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

# =============================
#         Load Balancer
# =============================

resource "azurerm_public_ip" "lb_public_ip" {
    name                = "lab-lb-ip"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    allocation_method   = "Static"
    sku                 = "Standard"
}

resource "azurerm_lb" "lab_lb" {
    name                = "lab-loadbalancer"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    sku                 = "Standard"

    frontend_ip_configuration {
        name                 = "PublicIPAddress"
        public_ip_address_id = azurerm_public_ip.lb_public_ip.id
    }
}

resource "azurerm_lb_backend_address_pool" "lb_backend_pool" {
    name                = "backend-pool"
    loadbalancer_id     = azurerm_lb.lab_lb.id
}

resource "azurerm_lb_probe" "http_probe" {
    name                = "http-probe"
    loadbalancer_id     = azurerm_lb.lab_lb.id
    protocol            = "Http"
    port                = 80
    request_path        = "/"
    interval_in_seconds = 5
    number_of_probes    = 2
}

resource "azurerm_lb_rule" "http_rule" {
    name                           = "http-rule"
    loadbalancer_id                = azurerm_lb.lab_lb.id
    protocol                       = "Tcp"
    frontend_port                  = 80
    backend_port                   = 80
    frontend_ip_configuration_name = "PublicIPAddress"
    backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_backend_pool.id]
    probe_id                       = azurerm_lb_probe.http_probe.id
}

# =============================
#             VM 1
# =============================

resource "azurerm_public_ip" "vm_public_ip" {
    name                = "lab-vm1-ip"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    allocation_method   = "Static"
    sku                 = "Standard"  # MODIFICADO: Cambiado de Basic a Standard
}

resource "azurerm_network_interface" "vm_nic" {
    name                = "lab-vm1-nic"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.subnet1.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
    }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
    network_interface_id      = azurerm_network_interface.vm_nic.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
    name                = "lab-vm1"
    resource_group_name = azurerm_resource_group.main.name
    location            = azurerm_resource_group.main.location
    size                = "Standard_B1s"
    admin_username      = "azureuser"
    network_interface_ids = [azurerm_network_interface.vm_nic.id]

    admin_ssh_key {
        username   = "azureuser"
        public_key = file("~/.ssh/id_rsa.pub")
    }

    os_disk {
        name                 = "lab-vm1-osdisk"
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "vm1_backend" {
    network_interface_id    = azurerm_network_interface.vm_nic.id
    ip_configuration_name   = "internal"
    backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_pool.id
}

# =============================
#             VM 2
# =============================

resource "azurerm_public_ip" "vm2_public_ip" {
    name                = "lab-vm2-ip"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    allocation_method   = "Static"
    sku                 = "Standard"  # MODIFICADO: Cambiado de Basic a Standard
}

resource "azurerm_network_interface" "vm2_nic" {
    name                = "lab-vm2-nic"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.subnet1.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.vm2_public_ip.id
    }
}

# NUEVO: Asociación de NSG para VM2 (igual que en VM1)
resource "azurerm_network_interface_security_group_association" "vm2_nic_nsg" {
    network_interface_id      = azurerm_network_interface.vm2_nic.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm2" {
    name                = "lab-vm2"
    resource_group_name = azurerm_resource_group.main.name
    location            = azurerm_resource_group.main.location
    size                = "Standard_B1s"
    admin_username      = "azureuser"
    network_interface_ids = [azurerm_network_interface.vm2_nic.id]

    admin_ssh_key {
        username   = "azureuser"
        public_key = file("~/.ssh/id_rsa.pub")
    }

    os_disk {
        name                 = "lab-vm2-osdisk"
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "vm2_backend" {
    network_interface_id    = azurerm_network_interface.vm2_nic.id
    ip_configuration_name   = "internal"
    backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_pool.id
}