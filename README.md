# Enterprise Database Migration and Security Lab

A hands-on infrastructure automation, database security, monitoring, and migration lab built on Ubuntu Server, KVM/libvirt, Terraform, Ansible, Jenkins, Python, and enterprise database platforms.

## Project goals

This lab simulates enterprise systems engineering responsibilities, including:

* Linux server administration
* Infrastructure as Code
* Virtual machine provisioning
* Configuration management
* Database deployment and security
* Database activity monitoring
* CI/CD automation
* Migration planning and validation
* Monitoring, logging, and alerting
* Failure recovery and operational documentation

## Current architecture

Dell Ubuntu Server

* KVM and QEMU
* libvirt
* libvirt NAT network
* `lab-test-01`

  * Manually created reference VM
* `tf-test-01`

  * Terraform-managed Ubuntu VM

## Current progress

### Completed

* Ubuntu Server host installation
* Hardware virtualisation verification
* KVM, QEMU, and libvirt installation
* Libvirt storage pool and NAT network configuration
* Manual Ubuntu cloud-image VM deployment
* Cloud-init user and SSH configuration
* Terraform installation and provider configuration
* Reusable Ubuntu QCOW2 base image
* Thin-provisioned QCOW2 overlay disk
* Terraform-generated cloud-init ISO
* Terraform-managed Ubuntu virtual machine
* DHCP address discovery through Terraform
* Terraform output for the VM IP address
* Terraform idempotency validation
* Local Git repository initialisation

### In progress

* GitHub repository setup
* Project documentation
* Ansible installation and inventory generation
* Reusable Linux server baseline

### Planned

* Jenkins CI/CD pipeline
* Oracle Database deployment
* Additional database platforms
* Database users, roles, privileges, and auditing
* Prometheus and Grafana monitoring
* Centralised logging
* Database activity monitoring simulation
* Migration inventory and wave planning
* Automated migration validation
* Failure simulations and rollback exercises

## Repository structure

* `terraform/environments/lab/`

  * Terraform configuration
  * Cloud-init templates
  * Libvirt domain configuration
  * Storage volume configuration
  * Network and IP outputs

Future directories will include:

* `ansible/`
* `jenkins/`
* `scripts/`
* `monitoring/`
* `database/`
* `docs/`

## Terraform workflow

Typical workflow:

```
terraform fmt
terraform validate
terraform plan
terraform apply
```

The current Terraform configuration provisions an Ubuntu virtual machine through libvirt using:

* A reusable Ubuntu cloud image
* A thin-provisioned QCOW2 overlay
* A generated cloud-init ISO
* SSH public-key authentication
* Libvirt DHCP lease discovery

## Security

The repository excludes generated or sensitive files, including:

* Terraform state
* Terraform saved plans
* Terraform provider binaries
* Private keys
* Environment files
* Virtual machine disk images
* Installation ISO files
* Ansible vault password files

No credentials, passwords, tokens, or private SSH keys should be committed.

## Project status

The virtualisation foundation and first Terraform provisioning workflow are complete.

The next major stage is Ansible-based Linux configuration management.
