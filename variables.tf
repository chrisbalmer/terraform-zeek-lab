variable "vsphere_server" {
  description = "The vCenter server to connect to."
  default     = "ops-vcenter-1.farm.oakops.io"
}

variable "op_subdomain" {
  description = "The subdomain for your 1Password account."
  default     = "my"
}

variable "vm_count" {
  description = "How many VMs of this type to create."
  default     = "3"
}

variable "vm_prefix" {
  description = "The prefix for the full VM name, i.e. dev, prod, etc"
  default     = "test"
}

variable "vm_name" {
  description = "The name of the VM, i.e. worker, master, etc"
  default     = "zeek"
}

variable "vm_domain_name" {
  description = "The domain name to assign to the VM."
  default     = "farm.oakops.io"
}

