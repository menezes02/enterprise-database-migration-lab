resource "libvirt_domain" "tf_test_01" {
  name        = var.vm_name
  type        = "kvm"
  memory      = var.vm_memory_mb
  memory_unit = "MiB"
  vcpu        = var.vm_vcpus

  running   = true
  autostart = false

  cpu = {
    mode = "host-passthrough"
  }

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
  }

  devices = {
    disks = [
      {
        device = "disk"

        driver = {
          type = "qcow2"
        }

        source = {
          file = {
            file = libvirt_volume.tf_test_01_disk.path
          }
        }

        target = {
          dev = "vda"
          bus = "virtio"
        }
      },
      {
        device    = "cdrom"
        read_only = true

        source = {
          file = {
            file = libvirt_volume.tf_test_01_cloudinit.path
          }
        }

        target = {
          dev = "sda"
          bus = "sata"
        }
      }
    ]

    interfaces = [
      {
        type = "network"

        model = {
          type = "virtio"
        }

        source = {
          network = {
            network = "default"
          }
        }
      }
    ]
  }
}
