provider "onepassword" {
  subdomain = var.op_subdomain
}

data "onepassword_vault" "op_homelab" {
  name = "homelab"
}

data "onepassword_item_login" "vcenter" {
  name  = "ops-vcenter-1"
  vault = data.onepassword_vault.op_homelab.name
}

data "onepassword_item_login" "ipa" {
  name  = "IPA_TERRAFORM_DNS_KEY"
  vault = data.onepassword_vault.op_homelab.name
}

data "onepassword_item_login" "workstation" {
  name  = "ops-workstation-1"
  vault = data.onepassword_vault.op_homelab.name
}

data "onepassword_item_login" "zeek" {
  name  = "Zeek Instances"
  vault = data.onepassword_vault.op_homelab.name
}

provider "vsphere" {
  user                 = data.onepassword_item_login.vcenter.username
  password             = data.onepassword_item_login.vcenter.password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
  version              = "1.11.0"
}

provider "dns" {
  update {
    server        = [for field in [for section in data.onepassword_item_login.ipa.section : section if section["name"] == ""][0].field : field if field["name"] == "server"][0]["string"]
    key_name      = "${data.onepassword_item_login.ipa.username}."
    key_algorithm = [for field in [for section in data.onepassword_item_login.ipa.section : section if section["name"] == ""][0].field : field if field["name"] == "algorithm"][0]["string"]
    key_secret    = data.onepassword_item_login.ipa.password
  }
  version = "2.2"
}

module "zeek_servers" {
  source           = "../terraform-vsphere-vm"
  vsphere_network  = "vlan14-servers"
  vsphere_template = "centos7-2020-04-16"
  node_count       = var.vm_count
  node_initial_key = [for field in [for section in data.onepassword_item_login.workstation.section : section if section["name"] == "Public"][0].field : field if field["name"] == "ssh_public_key"][0]["string"]
  node_name        = var.vm_name
  node_domain_name = var.vm_domain_name
  node_prefix      = var.vm_prefix
  node_ips = [
    "172.21.14.181/24",
    "172.21.14.182/24",
    "172.21.14.183/24"
  ]
  node_gateway            = "172.21.14.1"
  cloud_init              = true
  cloud_init_custom       = false
  cloud_config_template   = "centos-cloud-config.tpl"
  metadata_template       = "centos-metadata.tpl"
  network_config_template = "centos-network-config.tpl"
  cloud_user              = data.onepassword_item_login.zeek.username
  cloud_pass              = data.onepassword_item_login.zeek.password
}

resource "ansible_host" "zeek_servers" {
  count              = var.vm_count
  inventory_hostname = "${module.zeek_servers.vm_name[count.index]}.${var.vm_domain_name}"
  groups             = ["zeek"]
  vars = {
    ansible_user = data.onepassword_item_login.zeek.username
  }
}
