resource "libvirt_volume" "tf_test_01_cloudinit" {
  name = "${var.vm_name}-cloudinit.iso"
  pool = "default"

  create = {
    content = {
      url = libvirt_cloudinit_disk.tf_test_01.path
    }
  }
}

resource "libvirt_volume" "ubuntu_2404_base" {
  name = "ubuntu-24.04-base.qcow2"
  pool = "default"

  target = {
    format = {
      type = "qcow2"
    }
  }

  create = {
    content = {
      url = pathexpand(
        "~/cloud-images/ubuntu-24.04-server-cloudimg-amd64.img"
      )
    }
  }
}

resource "libvirt_volume" "tf_test_01_disk" {
  name     = "${var.vm_name}.qcow2"
  pool     = "default"
  capacity = var.vm_disk_size_bytes

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = libvirt_volume.ubuntu_2404_base.path

    format = {
      type = "qcow2"
    }
  }
}
