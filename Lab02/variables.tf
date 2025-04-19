variable "location" {
    default = "eastus"
    type    = string
}

variable "resource_group_name" {
    default = "rg-pauloenrique-lab"
    type    = string
}

variable "storage_account_name" {
    default = "paulostorage7450" # debe ser único, en minúsculas
    type    = string
}
