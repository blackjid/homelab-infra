resource "libvirt_volume" "node_boot" {
  count = length(var.ips)

  name           = "${var.name}-${count.index}.qcow2"
  pool           = var.storage_pool.name
  base_volume_id = var.base_volume.id
  size = var.boot_volume_size
}

data "template_file" "user_data" {
  count = length(var.ips)
  template = file("${path.module}/templates/cloud_init.cfg")

  vars = {  }
}

data "template_file" "meta_data" {
  count = length(var.ips)
  template = file("${path.module}/templates/meta_data.cfg")

  vars = {
    hostname = "${var.name}-${count.index}"
  }
}

data "template_file" "network_config" {
  count = length(var.ips)

  template = file("${path.module}/templates/network_config.cfg")

  vars = {
    network_address = var.ips[count.index]
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count = length(var.ips)


  name           = "commoninit-${var.name}-${count.index}.iso"
  meta_data      = data.template_file.meta_data[count.index].rendered
  user_data      = data.template_file.user_data[count.index].rendered
  network_config = data.template_file.network_config[count.index].rendered
  pool           = var.storage_pool.name
}

# volumes to attach to the "workers" domains as main disk
resource "libvirt_volume" "pv_volume" {
  count          = length(var.ips)

  name           = "${var.name}-${count.index}-pv.qcow2"
  size           = var.pv_volume_size
  pool           = var.pv_storage_pool.name
}

resource "libvirt_domain" "node" {
  count = length(var.ips)

  name   = "${var.name}-${count.index}"
  memory = "8192"
  vcpu   = 2

  cloudinit  = libvirt_cloudinit_disk.commoninit[count.index].id
  qemu_agent = true
  autostart  = true

  network_interface {
    bridge     = var.network_bridge.name
    addresses = [var.ips[count.index]]
    mac = var.macs[count.index]
    # hostname = "${var.name}-${count.index}" wait for PR to be merged
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.node_boot[count.index].id
  }

  disk {
    volume_id = libvirt_volume.pv_volume[count.index].id
    scsi      = "true"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

output "ips" {
  value = libvirt_domain.node.*.network_interface.0.addresses
}
