# Terraform Module: Zeek Lab

Lab environment for trying new Zeek configurations. This requires the vSphere port group to have promiscuous mode enabled.

## Tasks

- [X] Pull out variables
- [ ] {ANSIBLE} Add SSH host key lookup for workers
- [ ] {ANSIBLE} Add SSH known_hosts build for manager with worker keys using [Ansible known_hosts module](https://docs.ansible.com/ansible/latest/modules/known_hosts_module.html)
- [ ] {ANSIBLE} Move SSH authorized_key changes to the [Ansible authorized_key module](https://docs.ansible.com/ansible/latest/modules/authorized_key_module.html)
- [ ] {ANSIBLE} Add firewall config
  - Ports start at 47760 for standalone (was open on manager?), next port is manager, then one per logger, then one per proxy and finally one per worker. Each node is assigned its port on itself. So a host doing manager/logger/proxy gets 47760 - 47763, then individual workers would start at 47764 and go up from there. [Source 1](https://github.com/zeek/zeekctl#zeek-communication), [Source 2](https://stackoverflow.com/questions/56452326/bro-zeek-broctl-unable-to-find-peers)
- [ ] {ANSIBLE} Figure out service (start at boot)
- [ ] {ANSIBLE} Move pre configs to a role
- [ ] {ANSIBLE} Move log ACLs to a SplunkForwarder role and set that up to install Splunk UF
- [ ] {TERRAFORM} Fix terraform to apply VM separation for workers

## Requirements

- [terraform-provider-ansible](https://github.com/nbering/terraform-provider-ansible/): 1.0.3
