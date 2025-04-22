terraform {
    backend "azurerm" {
        resource_group_name  = "rg-terraform-state"
        storage_account_name = "terraformlab04"
        container_name       = "tfstate"
        key                  = "terraform.tfstate"
        access_key           = "123xyz"
        use_azuread_auth     = false  # Usar clave de acceso
        subscription_id      = "subscfoobarid"
        tenant_id            = "tenantfoobarid"

    }
}