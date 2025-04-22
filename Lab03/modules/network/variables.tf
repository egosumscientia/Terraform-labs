variable "resource_group_name" {
    description = "Name of the resource group"
    type        = string
}

variable "location" {
    description = "Azure region for resources"
    type        = string
}

variable "vnet_name" {
    description = "Name of the virtual network"
    type        = string
    default     = "module-vnet"
}

variable "vnet_address_space" {
    description = "Address space for the virtual network"
    type        = list(string)
    default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
    description = "Name of the subnet"
    type        = string
    default     = "internal"
}

variable "subnet_address_prefix" {
    description = "Address prefix for the subnet"
    type        = list(string)
    default     = ["10.0.1.0/24"]
}

variable "tags" {
    description = "Tags to apply to resources"
    type        = map(string)
    default     = {}
}