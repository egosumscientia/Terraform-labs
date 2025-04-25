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
    subscription_id = "foobar1"
    tenant_id       = "foobar2"
}

resource "azurerm_resource_group" "rg" {
name     = var.resource_group_name
location = var.location
}

resource "azurerm_virtual_network" "vnet" {
name                = "vnet-lab"
address_space       = ["10.0.0.0/16"]
location            = var.location
resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnet" {
name                 = "subnet-lab"
resource_group_name  = var.resource_group_name
virtual_network_name = azurerm_virtual_network.vnet.name
address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
name                = "publicip-lab"
location            = var.location
resource_group_name = var.resource_group_name
allocation_method   = "Dynamic"  # Cambiado a dinámico para aprovisionar automáticamente
}

resource "azurerm_network_interface" "nic" {
name                = "nic-lab"
location            = var.location
resource_group_name = var.resource_group_name

ip_configuration {
name                          = "internal"
subnet_id                     = azurerm_subnet.subnet.id
private_ip_address_allocation = "Dynamic"
public_ip_address_id          = azurerm_public_ip.pip.id
}
}

resource "azurerm_linux_virtual_machine" "vm" {
name                = "vm-ansible"
resource_group_name = var.resource_group_name
location            = var.location
size                = "Standard_B1s"
admin_username      = var.vm_admin_username
admin_password      = var.vm_admin_password
disable_password_authentication = false
network_interface_ids = [azurerm_network_interface.nic.id]

os_disk {
name              = "osdisk-lab"
caching           = "ReadWrite"
storage_account_type = "Standard_LRS"
}

source_image_reference {
publisher = "Canonical"
offer     = "UbuntuServer"
sku       = "18.04-LTS"
version   = "latest"
}
}

resource "null_resource" "ansible_provisioner" {
triggers = {
vm_id = azurerm_linux_virtual_machine.vm.id
pip_id = azurerm_public_ip.pip.id
}

provisioner "remote-exec" {
inline = [
    "sleep 120",
    "sudo apt update -y",
    "sudo apt install -y ansible",
    "echo '${file("ansible/playbook.yml")}' > playbook.yml",
    "ansible-playbook playbook.yml --connection=local"
]

connection {
    type     = "ssh"
    user     = var.vm_admin_username
    password = var.vm_admin_password
    host     = data.azurerm_public_ip.pip.ip_address  # ¡Este es el cambio crucial!
    timeout  = "10m"
}
}

depends_on = [
azurerm_linux_virtual_machine.vm,
azurerm_public_ip.pip,
azurerm_network_interface.nic
]
}

# Add this to get the IP address after it's assigned
data "azurerm_public_ip" "pip" {
name                = azurerm_public_ip.pip.name
resource_group_name = azurerm_linux_virtual_machine.vm.resource_group_name
depends_on = [azurerm_linux_virtual_machine.vm]
}
