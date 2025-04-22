# Crear grupo de recursos
resource "azurerm_resource_group" "rg" {
    name     = var.resource_group_name
    location = var.location
    tags = {
        Environment = var.environment
        Project     = "Terraform Modules Lab"
    }
}

# Uso del módulo de red
module "network" {
    source              = "./modules/network"
    resource_group_name = azurerm_resource_group.rg.name
    location            = var.location
    vnet_name           = "main-vnet-${var.environment}"
    vnet_address_space  = ["10.0.0.0/16"]
    subnet_name         = "internal-subnet"
    subnet_address_prefix = ["10.0.1.0/24"]
    tags = {
        Environment = var.environment
        Module      = "Network"
    }
}

# Uso del módulo de VM (con count para crear múltiples instancias)
module "vm" {
    source              = "./modules/vm"
    count               = var.vm_count
    resource_group_name = azurerm_resource_group.rg.name
    location            = var.location
    vm_name             = "vm-${var.environment}-${count.index + 1}"
    subnet_id           = module.network.subnet_id
    vm_size             = "Standard_B1s"
    tags = {
        Environment = var.environment
        Module      = "VM"
        Instance    = count.index + 1
    }
}

# Uso de un módulo de Terraform Registry (Storage Account)
module "storage_account" {
    source  = "Azure/avm-res-storage-storageaccount/azurerm"
    version             = "0.5.0"

    name = "storagedev2025"
    resource_group_name = azurerm_resource_group.rg.name
    location            = var.location
    account_kind        = "StorageV2"
    account_tier        = "Standard"
    account_replication_type = "LRS"
    tags = {
        Environment = var.environment
        Module      = "Storage"
    }
}

# Generar string aleatorio para nombre único del storage account
resource "random_string" "random" {
    length  = 8
    special = false
    upper   = false
}