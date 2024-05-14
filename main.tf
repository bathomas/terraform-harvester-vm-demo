data "harvester_image" "img" {
  display_name = var.img_display_name
  namespace    = "harvester-public"
}

data "harvester_ssh_key" "mysshkey" {
  name      = var.public_key
  namespace = var.namespace
}

resource "harvester_virtualmachine" "vm" {
  
  count = var.vm_count

  name                 = "${var.prefix}${format("%02d", count.index + 1)}"
  namespace            = var.namespace
  restart_after_update = true

  description = "Demo VM"

  tags = {
    ssh-user = "cloud-user"
  }

  cpu    = 2
  memory = "4Gi"

  efi         = true
  secure_boot = true

  run_strategy    = "RerunOnFailure"
  hostname        = "${var.prefix}${format("%02d", count.index + 1)}"
  reserved_memory = "100Mi"
  machine_type    = "q35"

  network_interface {
    name           = "nic-1"
    wait_for_lease = true
    type           = "bridge"
    network_name   = var.network_name
  }

  disk {
    name       = "rootdisk"
    type       = "disk"
    size       = "30Gi"
    bus        = "virtio"
    boot_order = 1

    image       = data.harvester_image.img.id
    auto_delete = true
  }

  ssh_keys = [
    harvester_ssh_key.mysshkey.id
  ]

}