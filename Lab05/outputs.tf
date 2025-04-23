output "vm_public_ip" {
    value = azurerm_public_ip.vm_ip.ip_address
}

output "ssh_connection_command" {
    value = "ssh ${var.admin_username}@${azurerm_public_ip.vm_ip.ip_address}"
}