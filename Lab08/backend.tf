terraform {
    backend "azurerm" {
        resource_group_name  = "rg-terra-lab08"
        storage_account_name = "saterralab08"
        container_name       = "terraform-state"
        key                  = "terraform.tfstate"
                                #clave de acceso
    }
}
