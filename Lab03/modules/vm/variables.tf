variable "resource_group_name" {
    description = "Name of the resource group"
    type        = string
}

variable "location" {
    description = "Azure region for resources"
    type        = string
}

variable "vm_name" {
    description = "Name of the virtual machine"
    type        = string
}

variable "subnet_id" {
    description = "ID of the subnet where the VM will be connected"
    type        = string
}

variable "vm_size" {
    description = "Size of the virtual machine"
    type        = string
    default     = "Standard_B1s"
}

variable "admin_username" {
    description = "Username for the VM admin account"
    type        = string
    default     = "adminuser"
}

variable "tags" {
    description = "Tags to apply to resources"
    type        = map(string)
    default     = {}
}