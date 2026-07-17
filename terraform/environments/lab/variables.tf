variable "vm_name" {
  description = "Name of the Terraform-managed virtual machine"
  type        = string
  default     = "tf-test-01"
}

variable "vm_memory_mb" {
  description = "Memory assigned to the VM in MiB"
  type        = number
  default     = 2048
}

variable "vm_vcpus" {
  description = "Number of virtual CPUs assigned to the VM"
  type        = number
  default     = 2
}

variable "vm_disk_size_bytes" {
  description = "Virtual disk capacity in bytes"
  type        = number
  default     = 21474836480
}
