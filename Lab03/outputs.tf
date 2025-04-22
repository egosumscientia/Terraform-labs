output "resource_group_name" {
    description = "Resource group name"
    value       = azurerm_resource_group.rg.name
}

output "virtual_network_name" {
    description = "Virtual network name"
    value       = module.network.vnet_name
}

output "virtual_machines" {
    description = "Virtual machine details"
    value = [
        for i, vm in module.vm : {
            name    = vm.vm_name
            ip      = vm.private_ip_address
        }
    ]
}

output "storage_account_name" {
    description = "Storage account name"
    value       = module.storage_account.name
}