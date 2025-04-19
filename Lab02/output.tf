output "created_resource_group" {
    value = azurerm_resource_group.paulo_rg.name
}

output "storage_account_blob_url" {
    value = azurerm_storage_account.paulo_storage.primary_blob_endpoint
}

output "terraform_user_email" {
    value = "petorovalder@hotmail.com"
}

output "azure_subscription_id" {
    value = "5f55b5a1-09ef-4b87-b02d-30e1a8347b3d"
}
