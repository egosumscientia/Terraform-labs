output "resource_group_name" {
    description = "El nombre del Resource Group creado"
    value       = azurerm_resource_group.example.name
}  

output "storage_account_primary_web_endpoint" {
    description = "El endpoint primario del Storage Account"
    value       = azurerm_storage_account.example.primary_web_endpoint
}
