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

  vars = {
    sudo_password       = var.sudo_password
    k3s_token           = var.k3s_token
    k3s_master_hostname = var.k3s_master_hostname
  }
}

data "template_file" "meta_data" {
  count = length(var.ips)
  template = file("${path.module}/templates/meta_data.cfg")

  vars = {
    hostname = "${var.name}-${count.index}"
  }
}

data "template_file" "gpu_passthrough" {
  count = length(var.gpu_guids)
  template = file("${path.module}/templates/gpu_passthrough.xsl")

  vars = {
    gpu_guid = "${var.gpu_guids[count.index]}"
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
  cmdline = []
  qemu_agent = true
  autostart  = true

  network_interface {
    bridge     = var.network_bridge.name
    mac = var.macs[count.index]
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

  dynamic "xml" {
    for_each = var.gpu_guids[count.index] != "" ? [1] : []
    content {
      xslt = data.template_file.gpu_passthrough[count.index].rendered
    }
  }
}

output "ips" {
  value = libvirt_domain.node.*.network_interface.0.addresses
}
