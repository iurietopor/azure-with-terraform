variable "resource_group_location" {
  default     = "westeurope"
  description = "Location of thr resource group."
}

variable "resource_group_name_prefix" {
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in my Azure subscription."
}

