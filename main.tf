terraform {
  required_providers {
    ansible = {
      source  = "github.com/nbering/terraform-provider-ansible"
      version = "v1.0.3"
    }

    dns = {
      version = "2.2"
    }

    onepassword = {
      source  = "github.com/anasinnyk/terraform-provider-1password"
      version = "0.5"
    }

    template = {
      version = "2.1"
    }

    vsphere = {
      version = "1.11.0"
    }
  }
}

provider "onepassword" {
  subdomain = var.op_subdomain
}

provider "vsphere" {
  user                 = data.onepassword_item_login.vcenter.username
  password             = data.onepassword_item_login.vcenter.password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

provider "dns" {
  update {
    server        = [for field in [for section in data.onepassword_item_login.ipa.section : section if section["name"] == ""][0].field : field if field["name"] == "server"][0]["string"]
    key_name      = "${data.onepassword_item_login.ipa.username}."
    key_algorithm = [for field in [for section in data.onepassword_item_login.ipa.section : section if section["name"] == ""][0].field : field if field["name"] == "algorithm"][0]["string"]
    key_secret    = data.onepassword_item_login.ipa.password
  }
}

module "servers" {
  source                  = "github.com/chrisbalmer/terraform-vsphere-vm?ref=0.2"
  vsphere_network         = var.vm_network
  vsphere_template        = var.vm_template
  node_count              = var.vm_count
  node_initial_key        = [for field in [for section in data.onepassword_item_login.workstation.section : section if section["name"] == "Public"][0].field : field if field["name"] == "ssh_public_key"][0]["string"]
  node_name               = var.vm_name
  node_domain_name        = var.vm_domain_name
  node_prefix             = var.vm_prefix
  node_ips                = var.vm_ip_addresses
  node_gateway            = var.vm_gateway
  cloud_init              = true
  cloud_init_custom       = false
  cloud_config_template   = var.cloud_config_template
  metadata_template       = var.metadata_template
  network_config_template = var.network_config_template
  cloud_user              = data.onepassword_item_login.vm.username
  cloud_pass              = data.onepassword_item_login.vm.password
}

data "onepassword_vault" "op_homelab" {
  name = var.op_vault
}

data "onepassword_item_login" "vcenter" {
  name  = var.op_vcenter_login
  vault = data.onepassword_vault.op_homelab.name
}

data "onepassword_item_login" "ipa" {
  name  = var.op_ipa_login
  vault = data.onepassword_vault.op_homelab.name
}

data "onepassword_item_login" "workstation" {
  name  = var.op_workstation_login
  vault = data.onepassword_vault.op_homelab.name
}

data "onepassword_item_login" "vm" {
  name  = var.op_vm_login
  vault = data.onepassword_vault.op_homelab.name
}

resource "ansible_host" "servers" {
  count              = var.vm_count
  inventory_hostname = "${module.servers.vm_name[count.index]}.${var.vm_domain_name}"
  groups             = var.ansible_groups
  vars = {
    ansible_user            = data.onepassword_item_login.vm.username
    ansible_ssh_common_args = "-o StrictHostKeyChecking=${var.ansible_hostkey_checking}"
  }
}
