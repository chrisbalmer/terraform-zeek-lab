variable "op_vm_login" {
  description = "Login for the VMs"
  default     = "Zeek Instances"
}

variable "ansible_groups" {
  description = "Ansible groups for the VMs."
  default = [
    "zeek"
  ]
}

variable "vsphere_server" {
  description = "The vCenter server to connect to."
  default     = "ops-vcenter-1.farm.oakops.io"
}

variable "vm_count" {
  description = "How many VMs of this type to create."
  default     = "3"
}

variable "vm_prefix" {
  description = "The prefix for the full VM names, i.e. dev, prod, etc"
  default     = "test"
}

variable "vm_name" {
  description = "The name of the VMs, i.e. worker, master, etc"
  default     = "zeek"
}

variable "vm_network" {
  description = "The virtual network to connect to in vSphere."
  default     = "vlan14-servers"
}

variable "vm_ip_addresses" {
  description = "IP addresses to assign to the VMs."
  default = [
    "172.21.14.181/24",
    "172.21.14.182/24",
    "172.21.14.183/24"
  ]
}

variable "vm_gateway" {
  description = "The gateway for the VM network adapters."
  default     = "172.21.14.1"
}

variable "vm_domain_name" {
  description = "The domain name to assign to the VMs."
  default     = "farm.oakops.io"
}

variable "vm_template" {
  description = "The template to clone for the VMs."
  default     = "centos7-2020-04-16"
}

variable "cloud_config_template" {
  description = "Cloud config template for the cloning process."
  default     = "centos-cloud-config.tpl"
}

variable "metadata_template" {
  description = "Metadata template for the cloning process."
  default     = "centos-metadata.tpl"
}

variable "network_config_template" {
  description = "Network config template for the cloning process."
  default     = "centos-network-config.tpl"
}

variable "op_subdomain" {
  description = "The subdomain for your 1Password account."
  default     = "my"
}

variable "op_vault" {
  description = "Vault with the passwords for this module."
  default     = "homelab"
}

variable "op_vcenter_login" {
  description = "Login for vCenter."
  default     = "ops-vcenter-1"
}

variable "op_ipa_login" {
  description = "Login for IPA."
  default     = "IPA_TERRAFORM_DNS_KEY"
}

variable "op_workstation_login" {
  description = "Login for the workstation with the SSH key."
  default     = "ops-workstation-1"
}

variable "ansible_hostkey_checking" {
  description = "Whether or not to enable strict host key checking."
  default     = "no"
}
