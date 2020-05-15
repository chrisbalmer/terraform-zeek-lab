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

  backend "s3" {
    bucket                      = "terraform"
    key                         = "labs/zeek"
    region                      = "us-east-1"
    endpoint                    = "https://nas.balmerfamilyfarm.com:9000"
    profile                     = "nas"
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_get_ec2_platforms      = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
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
  #source                  = "github.com/chrisbalmer/terraform-vsphere-vm?ref=0.2"
  source                  = "../terraform-vsphere-vm/"
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

module "workers" {
  source                  = "github.com/chrisbalmer/terraform-vsphere-vm?ref=0.3"
  vsphere_network         = var.worker_networks
  vsphere_template        = var.vm_template
  node_count              = var.worker_count
  node_initial_key        = [for field in [for section in data.onepassword_item_login.workstation.section : section if section["name"] == "Public"][0].field : field if field["name"] == "ssh_public_key"][0]["string"]
  node_name               = var.worker_name
  node_domain_name        = var.vm_domain_name
  node_prefix             = var.vm_prefix
  node_ips                = var.worker_ip_addresses
  node_gateway            = var.worker_gateway
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

resource "ansible_host" "managers" {
  count              = var.vm_count
  inventory_hostname = "${module.servers.vm_name[count.index]}.${var.vm_domain_name}"
  groups             = var.manager_groups
}

resource "ansible_host" "workers" {
  count              = var.worker_count
  inventory_hostname = "${module.workers.vm_name[count.index]}.${var.vm_domain_name}"
  groups             = var.worker_groups
  vars = {
    zeek_interface = var.worker_interface
  }
}

resource "ansible_group" "zeek" {
  inventory_group_name = "zeek"
  vars = {
    ansible_user            = data.onepassword_item_login.vm.username
    ansible_ssh_common_args = "-o StrictHostKeyChecking=${var.ansible_hostkey_checking}"
  }
}

resource "ansible_group" "zeek_manager" {
  inventory_group_name = "zeek_manager"
  vars = {
    zeek_node_logger  = "${module.servers.vm_name[0]}.${var.vm_domain_name}"
    zeek_node_manager = "${module.servers.vm_name[0]}.${var.vm_domain_name}"
    zeek_node_proxy   = "${module.servers.vm_name[0]}.${var.vm_domain_name}"
  }
}
