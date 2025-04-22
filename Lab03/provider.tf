terraform {
    required_providers {
    azurerm = {
        source  = "hashicorp/azurerm"
        version = ">= 3.85.0, < 5.0.0"
    }
}
required_version = ">= 1.0.0"
}

provider "azurerm" {
    features {}
    subscription_id = "5f55b5a1-09ef-4b87-b02d-30e1a8347b3d"
    tenant_id       = "093c684c-622c-4a8c-9180-47802a4d322a"
}