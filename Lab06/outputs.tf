output "public_ip_address" {
    value = azurerm_public_ip.pip.ip_address != "" ? azurerm_public_ip.pip.ip_address : "IP no asignada (verificar en Portal)"
}
