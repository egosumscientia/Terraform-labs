resource "azurerm_resource_group" "paulo_rg" {
    name     = var.resource_group_name
    location = var.location
}

resource "azurerm_storage_account" "paulo_storage" {
    name                     = var.storage_account_name
    resource_group_name      = azurerm_resource_group.paulo_rg.name
    location                 = azurerm_resource_group.paulo_rg.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}

resource "azurerm_storage_container" "paulo_container" {
    name                  = "public-container"
    storage_account_name  = azurerm_storage_account.paulo_storage.name
    container_access_type = "blob"  # permite acceso público SOLO a blobs (no listado de contenedor)
}

