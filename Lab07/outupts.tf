output "vm1_public_ip" {
    value = azurerm_public_ip.vm_public_ip.ip_address
}

output "vm2_public_ip" {
    value = azurerm_public_ip.vm2_public_ip.ip_address
}

output "load_balancer_ip" {
    value = azurerm_public_ip.lb_public_ip.ip_address
}
