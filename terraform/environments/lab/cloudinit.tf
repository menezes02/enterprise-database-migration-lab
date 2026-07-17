resource "libvirt_cloudinit_disk" "tf_test_01" {
  name      = "${var.vm_name}-cloudinit.iso"
  user_data = local.user_data
  meta_data = local.meta_data
}
