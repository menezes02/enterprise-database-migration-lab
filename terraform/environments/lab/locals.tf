locals {
  ssh_public_key = trimspace(
    file(pathexpand("~/.ssh/lab_ed25519.pub"))
  )

  user_data = templatefile(
    "${path.module}/cloud-init/user-data.yaml.tftpl",
    {
      vm_name        = var.vm_name
      ssh_public_key = local.ssh_public_key
    }
  )

  meta_data = templatefile(
    "${path.module}/cloud-init/meta-data.yaml.tftpl",
    {
      vm_name = var.vm_name
    }
  )
}
