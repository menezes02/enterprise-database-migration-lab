# Enterprise Database Migration and Security Lab

A hands-on infrastructure automation, Linux security, database engineering, monitoring, and migration lab built on Ubuntu Server, KVM/libvirt, Terraform, Ansible, GitHub, and Python.

The project is designed to reproduce the engineering principles used in a large enterprise environment through a smaller representative lab.

## Project purpose

This lab demonstrates practical experience with:

* Linux systems administration
* Virtualisation with KVM, QEMU, and libvirt
* Infrastructure as Code with Terraform
* Configuration management with Ansible
* Secure server baseline automation
* Git-based change control
* Database deployment and security
* Database migration planning and validation
* Monitoring, logging, and auditing
* CI/CD orchestration
* Failure recovery and operational documentation

The final objective is to simulate an enterprise database migration and security platform using a small number of virtual machines and a larger generated application and database inventory.

## Current architecture

```text
Dell OptiPlex 7050
Ubuntu Server 24.04 LTS
│
├── KVM
├── QEMU
├── libvirt
├── Terraform
├── Ansible
├── Git
│
├── libvirt default NAT network
│   └── 192.168.122.0/24
│
├── lab-test-01
│   ├── Manually created reference VM
│   ├── Ubuntu Server 24.04
│   └── 192.168.122.125
│
└── tf-test-01
    ├── Terraform-managed VM
    ├── Ubuntu Server 24.04
    ├── 2 vCPUs
    ├── 2 GiB RAM
    ├── 20 GiB QCOW2 disk
    ├── Cloud-init configuration
    └── 192.168.122.151
```

## Automation workflow

```text
Terraform configuration
        ↓
libvirt provider
        ↓
KVM virtual machine
        ↓
Cloud-init bootstrap
        ↓
Terraform IP output
        ↓
Inventory-generation script
        ↓
Ansible inventory
        ↓
Linux security baseline
        ↓
Validation and idempotency testing
```

## Current progress

### Completed

#### Infrastructure foundation

* Installed Ubuntu Server 24.04 LTS on the physical Dell host
* Verified Intel VT-x hardware virtualisation
* Verified access to `/dev/kvm`
* Installed KVM, QEMU, libvirt, and supporting tools
* Configured the default libvirt NAT network
* Configured the default libvirt storage pool
* Verified DHCP, DNS, routing, and internet access
* Configured SSH and Tailscale access to the host

#### Manual virtual machine deployment

* Downloaded and verified an Ubuntu cloud image
* Created a manually managed QCOW2 virtual machine
* Configured cloud-init
* Configured SSH public-key authentication
* Tested VM lifecycle operations
* Inspected libvirt XML, disks, interfaces, and networking
* Recovered a VM definition while preserving its disk and data

#### Terraform

* Installed Terraform from the HashiCorp repository
* Configured the `dmacvicar/libvirt` provider
* Imported a reusable Ubuntu QCOW2 base image
* Created a thin-provisioned QCOW2 overlay disk
* Generated a cloud-init ISO
* Created and started a libvirt domain
* Connected the VM to the default NAT network
* Retrieved DHCP interface information
* Exposed the Terraform-managed VM IP as an output
* Verified Terraform state
* Verified Terraform idempotency

A successful Terraform plan currently returns:

```text
No changes. Your infrastructure matches the configuration.
```

#### Git and GitHub

* Initialised a Git repository
* Added a secure `.gitignore`
* Excluded Terraform state, plans, provider files, images, and secrets
* Added commit identity using a GitHub no-reply address
* Created a private GitHub repository
* Pushed the `main` branch
* Maintained incremental commits for each working milestone

#### Ansible

* Installed Ansible Core
* Created a project-specific `ansible.cfg`
* Created a YAML inventory
* Configured SSH-agent authentication
* Verified Ansible connectivity with the `ping` module
* Gathered operating-system facts
* Created a verification playbook
* Created a reusable `linux_baseline` role
* Added environment-specific variables through `group_vars`
* Added modular task files and tags
* Generated the Ansible inventory from Terraform output
* Tested Ansible check mode
* Verified Ansible idempotency

A repeated baseline run currently returns:

```text
changed=0
unreachable=0
failed=0
```

## Terraform implementation

The Terraform configuration manages:

* Ubuntu cloud base image
* Terraform-managed QCOW2 overlay disk
* Cloud-init ISO
* libvirt virtual machine domain
* CPU and memory allocation
* Virtual network interface
* DHCP address lookup
* Terraform outputs

The environment is stored under:

```text
terraform/environments/lab/
```

### Terraform workflow

```bash
cd terraform/environments/lab

terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
```

To retrieve only the Terraform-managed VM IP:

```bash
terraform output -raw tf_test_01_ip
```

Terraform can also be used from the repository root:

```bash
terraform -chdir=terraform/environments/lab plan
```

## Terraform-to-Ansible integration

Terraform retrieves the VM address through the libvirt DHCP lease data source.

The inventory-generation script reads the Terraform output and writes the current address into the Ansible inventory.

Run:

```bash
./scripts/generate-ansible-inventory.sh
```

Example output:

```text
Generated Ansible inventory:
  VM: tf-test-01
  IP: 192.168.122.151
  File: ansible/inventories/lab/hosts.yml
```

This removes the need to manually search for the VM address with `virsh`.

## Ansible Linux baseline

The `linux_baseline` role applies a reusable security and administration baseline to Terraform-managed Ubuntu virtual machines.

### Managed packages

The role ensures the following packages are present:

* `auditd`
* `ca-certificates`
* `curl`
* `git`
* `htop`
* `jq`
* `ufw`
* `unzip`
* `vim`

### Managed services

The role ensures:

* `auditd` is enabled and running
* `systemd-timesyncd` is enabled and running
* The system clock is synchronized
* The server uses UTC

### SSH hardening

The role manages an OpenSSH drop-in configuration:

```text
/etc/ssh/sshd_config.d/00-linux-baseline.conf
```

The effective SSH security settings include:

```text
Port 22
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
X11Forwarding no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
```

The SSH configuration is validated with:

```bash
/usr/sbin/sshd -t
```

The SSH service is restarted through an Ansible handler only when the managed configuration changes.

The deployment process is designed to reduce lockout risk:

```text
Render configuration
        ↓
Validate candidate configuration
        ↓
Install managed configuration
        ↓
Validate full SSH configuration
        ↓
Restart SSH through handler
        ↓
Test a new Ansible connection
```

### UFW firewall

The baseline manages UFW using the `community.general.ufw` module.

The firewall configuration includes:

* Allow SSH on TCP port 22
* Deny incoming traffic by default
* Allow outgoing traffic by default
* Enable low-level firewall logging
* Enable UFW

The SSH allow rule is created before UFW is enabled.

Current firewall status:

```text
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing)
22/tcp ALLOW IN
```

### Environment variables

The lab environment variables are stored in:

```text
ansible/inventories/lab/group_vars/all.yml
```

They include:

```yaml
linux_baseline_timezone: Etc/UTC
linux_baseline_environment: Lab
linux_baseline_ssh_port: 22
linux_baseline_manage_firewall: true
linux_baseline_motd_title: Enterprise Database Migration and Security Lab
```

The role also contains reusable defaults.

Firewall management is disabled by default in the role and explicitly enabled by the lab inventory.

### Ansible tags

The role supports selective execution through tags:

```text
packages
services
ssh
security
firewall
```

Examples:

```bash
ansible-playbook playbooks/linux-baseline.yml --tags packages
ansible-playbook playbooks/linux-baseline.yml --tags services
ansible-playbook playbooks/linux-baseline.yml --tags ssh
ansible-playbook playbooks/linux-baseline.yml --tags firewall
ansible-playbook playbooks/linux-baseline.yml --tags security
```

### Ansible workflow

Generate the current inventory:

```bash
./scripts/generate-ansible-inventory.sh
```

Enter the Ansible directory:

```bash
cd ansible
```

Verify the inventory:

```bash
ansible-inventory --graph
ansible-inventory --host tf-test-01
```

Test connectivity:

```bash
ansible terraform_vms -m ping
```

Check playbook syntax:

```bash
ansible-playbook playbooks/linux-baseline.yml --syntax-check
```

Preview changes:

```bash
ansible-playbook playbooks/linux-baseline.yml --check
```

Apply the baseline:

```bash
ansible-playbook playbooks/linux-baseline.yml
```

Run it again to verify idempotency:

```bash
ansible-playbook playbooks/linux-baseline.yml
```

Expected second-run recap:

```text
changed=0
unreachable=0
failed=0
```

## Ansible collection dependencies

The project uses:

```text
community.general 8.3.0
```

Dependencies are recorded in:

```text
ansible/collections/requirements.yml
```

Install them with:

```bash
cd ansible

ansible-galaxy collection install \
  -r collections/requirements.yml
```

## Repository structure

```text
.
├── .gitignore
├── README.md
│
├── terraform/
│   └── environments/
│       └── lab/
│           ├── cloud-init/
│           │   ├── meta-data.yaml.tftpl
│           │   └── user-data.yaml.tftpl
│           ├── .terraform.lock.hcl
│           ├── cloudinit.tf
│           ├── domain.tf
│           ├── locals.tf
│           ├── provider.tf
│           ├── read-only.tf
│           ├── variables.tf
│           ├── versions.tf
│           └── volumes.tf
│
├── ansible/
│   ├── ansible.cfg
│   ├── collections/
│   │   └── requirements.yml
│   ├── inventories/
│   │   └── lab/
│   │       ├── hosts.yml
│   │       └── group_vars/
│   │           └── all.yml
│   ├── playbooks/
│   │   ├── verify.yml
│   │   └── linux-baseline.yml
│   └── roles/
│       └── linux_baseline/
│           ├── defaults/
│           │   └── main.yml
│           ├── handlers/
│           │   └── main.yml
│           ├── tasks/
│           │   ├── main.yml
│           │   ├── packages.yml
│           │   ├── services.yml
│           │   ├── ssh.yml
│           │   └── firewall.yml
│           └── templates/
│               └── 00-linux-baseline.conf.j2
│
└── scripts/
    └── generate-ansible-inventory.sh
```

## Security controls

The repository excludes sensitive and generated files, including:

* Terraform state
* Terraform state backups
* Terraform plan files
* Terraform provider binaries
* Private SSH keys
* Environment files
* Virtual-machine disk images
* ISO installation files
* Ansible Vault password files
* Credentials and tokens

The following files must never be committed:

```text
*.tfstate
*.tfstate.*
*.tfvars
*.plan
.env
*.pem
*.key
id_rsa
id_ed25519
vault-password*
```

Before committing, the repository can be checked with:

```bash
git diff --check
```

A basic secret scan can also be performed:

```bash
grep -RInE \
'BEGIN .*PRIVATE KEY|gho_|github_pat_|password[[:space:]]*=|token[[:space:]]*=|secret[[:space:]]*=' \
. \
--exclude-dir=.git \
--exclude-dir=.terraform \
--exclude='*.tfstate' \
--exclude='*.tfstate.*' \
--exclude='*.plan'
```

## Design principles

This project follows several enterprise engineering principles.

### Infrastructure as Code

Virtual-machine configuration is declared in Terraform rather than manually recreated.

### Configuration as Code

Linux security and operating-system settings are managed through Ansible roles and playbooks.

### Idempotency

Repeated Terraform and Ansible runs produce no changes when the environment already matches the desired state.

### Separation of responsibilities

```text
Terraform
└── Provisions infrastructure

Cloud-init
└── Performs first-boot configuration

Ansible
└── Applies and maintains operating-system configuration

GitHub
└── Stores code and change history

Jenkins
└── Will orchestrate the complete workflow
```

### Safe change management

* Terraform plans are reviewed before applying
* Ansible check mode is used before deployment
* SSH configurations are validated before restart
* SSH is allowed before enabling the firewall
* Existing sessions remain open during SSH and firewall changes
* Every functional milestone is committed separately

### Reproducibility

The environment can be rebuilt from:

* Terraform configuration
* Cloud-init templates
* Ansible inventory generation
* Ansible roles
* Collection dependency files
* Git history

## Planned next stages

### Complete the Ansible section

* Add a managed login banner
* Create a dedicated validation playbook
* Add package and service assertions
* Add `ansible-lint`
* Add Ansible Vault fundamentals
* Test baseline persistence after reboot
* Expand role documentation

### Jenkins

* Install Jenkins
* Create a Jenkins pipeline
* Run Terraform format and validation checks
* Run Terraform plan and apply stages
* Generate the Ansible inventory
* Run Ansible syntax and lint checks
* Apply the Linux baseline
* Run post-deployment validation

### Database platform

* Deploy Oracle Database Free
* Configure listener and services
* Create users, schemas, roles, and privileges
* Configure database auditing
* Add backup and restore exercises
* Add Python database connectivity
* Add additional database platforms

### Monitoring and database activity monitoring

* Deploy Prometheus
* Deploy Grafana
* Add centralised logging
* Collect Linux and database audit events
* Simulate database activity monitoring policies
* Create security alerts and dashboards

### Migration factory

* Generate a simulated server inventory
* Generate application and database records
* Create migration waves
* Implement migration pre-checks
* Implement post-migration validation
* Add reporting and rollback procedures

### Resilience

* Simulate service failures
* Simulate SSH configuration failures
* Test rollback procedures
* Test VM recreation
* Test backup and restore
* Document incident-response procedures

## Interview demonstration

A short demonstration can use the following workflow.

Show recent Git history:

```bash
git log --oneline --decorate -10
```

Show Terraform idempotency:

```bash
terraform -chdir=terraform/environments/lab plan
```

Generate the Ansible inventory:

```bash
./scripts/generate-ansible-inventory.sh
```

Show the inventory:

```bash
cd ansible
ansible-inventory --graph
```

Test connectivity:

```bash
ansible terraform_vms -m ping
```

Show available role tags:

```bash
ansible-playbook playbooks/linux-baseline.yml --list-tags
```

Run the complete baseline:

```bash
ansible-playbook playbooks/linux-baseline.yml
```

A successful demonstration ends with:

```text
changed=0
unreachable=0
failed=0
```

This proves that the Terraform-managed infrastructure and Ansible-managed operating-system configuration already match the desired state.

## Project status

The virtualisation, Terraform, GitHub, and core Ansible foundations are operational.

Current working capabilities include:

```text
Terraform VM provisioning
Cloud-init bootstrap
Terraform DHCP discovery
Generated Ansible inventory
Reusable Linux baseline
Package management
Audit service enforcement
Time synchronization
SSH hardening
UFW firewall management
Tagged Ansible execution
Check mode
Idempotency validation
GitHub change history
```

The next major milestone is completing Ansible validation and documentation, followed by Jenkins pipeline orchestration and database deployment.

## Disclaimer

This project is a personal technical lab built for learning and demonstration purposes.

It is not connected to, endorsed by, or representative of any employer’s real production infrastructure. It uses a small lab environment to demonstrate general enterprise engineering principles such as automation, security, repeatability, validation, and change control.
