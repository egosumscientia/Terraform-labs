output "vm_id" {
    description = "ID of the virtual machine"
    value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_name" {
    description = "Name of the virtual machine"
    value       = azurerm_linux_virtual_machine.vm.name
}

output "private_ip_address" {
    description = "Private IP address of the VM"
    value       = azurerm_network_interface.nic.private_ip_address
}