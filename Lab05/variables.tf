variable "location" {
    description = "Azure region where resources will be created"
    type        = string
    default     = "eastus"
}

variable "admin_username" {
    description = "Username for the VM admin account"
    type        = string
    default     = "adminuser"
}

variable "vm_size" {
    description = "Size of the virtual machine"
    type        = string
    default     = "Standard_F2"
}