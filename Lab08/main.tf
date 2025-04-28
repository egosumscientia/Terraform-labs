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
    subscription_id = "fooid"
    tenant_id       = "foobar"
}


resource "azurerm_resource_group" "example" {
    name     = var.resource_group_name
    location = var.resource_group_location
}

resource "azurerm_storage_account" "example" {
    name                     = var.storage_account_name
    resource_group_name      = azurerm_resource_group.example.name
    location                 = azurerm_resource_group.example.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}
