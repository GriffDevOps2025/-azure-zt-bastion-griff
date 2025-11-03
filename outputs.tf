output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.main.name
}

output "vm_name" {
  description = "Virtual machine name"
  value       = azurerm_linux_virtual_machine.main.name
}

output "vm_private_ip" {
  description = "VM private IP address"
  value       = azurerm_network_interface.vm.private_ip_address
}

output "bastion_host_name" {
  description = "Bastion host name"
  value       = azurerm_bastion_host.main.name
}

output "admin_username" {
  description = "Admin username"
  value       = var.admin_username
}

output "ssh_command" {
  description = "SSH command (use via Bastion only)"
  value       = "ssh ${var.admin_username}@${azurerm_network_interface.vm.private_ip_address}"
}

output "next_steps" {
  description = "Instructions"
  value       = <<-EOT
    
    ✅ Infrastructure deployed successfully!
    
    🔐 Connect to VM via Azure Bastion:
    1. Go to: https://portal.azure.com
    2. Navigate to: Virtual Machines → ${azurerm_linux_virtual_machine.main.name}
    3. Click: Connect → Bastion
    4. Username: ${var.admin_username}
    5. Use SSH private key: $HOME/.ssh/azure_bastion_key
    
    💰 COST: ~$2.64/day while running
    🗑️  DESTROY: terraform destroy -auto-approve
  EOT
}