variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-ztb-griff"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "vnet_address_space" {
  description = "Address space for VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "bastion_subnet_prefix" {
  description = "Address prefix for Azure Bastion subnet"
  type        = string
  default     = "10.0.1.0/26"
}

variable "private_subnet_prefix" {
  description = "Address prefix for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "admin_username" {
  description = "Admin username for VM"
  type        = string
  default     = "griff"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/azure_bastion_key.pub"
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_B1s"
}

variable "prefix" {
  description = "Resource naming prefix"
  type        = string
  default     = "ztb-griff"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Demo"
    Project     = "ZeroTrustBastion"
    ManagedBy   = "Terraform"
    Owner       = "griff"
  }
}