data "libvirt_domain_interface_addresses" "lab_test_01" {
  domain = "lab-test-01"
  source = "lease"
}

output "lab_test_01_interfaces" {
  description = "Network interfaces and DHCP addresses reported by libvirt"
  value       = data.libvirt_domain_interface_addresses.lab_test_01.interfaces
}

data "libvirt_domain_interface_addresses" "tf_test_01" {
  domain = libvirt_domain.tf_test_01.name
  source = "lease"
}

output "tf_test_01_interfaces" {
  description = "Network interfaces and DHCP addresses for the Terraform-managed VM"
  value       = data.libvirt_domain_interface_addresses.tf_test_01.interfaces
}

output "tf_test_01_ip" {
  description = "IPv4 address of the Terraform-managed VM"
  value       = data.libvirt_domain_interface_addresses.tf_test_01.interfaces[0].addrs[0].addr
}
