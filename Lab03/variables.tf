variable "resource_group_name" {
    description = "Name of the resource group"
    type        = string
    default     = "terraform-modules-rg"
}

variable "location" {
    description = "Azure region for resources"
    type        = string
    default     = "eastus"
}

variable "environment" {
    description = "Environment name (dev, test, prod)"
    type        = string
    default     = "dev"
}

variable "vm_count" {
    description = "Number of VMs to create"
    type        = number
    default     = 2
}