#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="$PROJECT_ROOT/terraform/environments/lab"
INVENTORY_FILE="$PROJECT_ROOT/ansible/inventories/lab/hosts.yml"

VM_IP="$(terraform -chdir="$TERRAFORM_DIR" output -raw tf_test_01_ip)"

if [[ -z "$VM_IP" ]]; then
    echo "Error: Terraform did not return an IP address." >&2
    exit 1
fi

cat > "$INVENTORY_FILE" <<EOF
all:
  children:
    terraform_vms:
      hosts:
        tf-test-01:
          ansible_host: $VM_IP
  vars:
    ansible_user: zintek
    ansible_python_interpreter: /usr/bin/python3
EOF

echo "Generated Ansible inventory:"
echo "  VM: tf-test-01"
echo "  IP: $VM_IP"
echo "  File: $INVENTORY_FILE"
