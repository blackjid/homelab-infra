provider "libvirt" {
  uri = "qemu+ssh://${var.virt_host}:22/system?socket=/var/run/libvirt/libvirt-sock"
}

resource "libvirt_pool" "base" {
  name = "base"
  type = "dir"
  path = "/var/lib/libvirt/images/base"
}

resource "libvirt_pool" "default" {
  name = "default"
  type = "dir"
  path = "/var/lib/libvirt/images/default"
}

resource "libvirt_pool" "longhorn" {
  name = "longhorn"
  type = "dir"
  path = "/mnt/longhorn"
}

resource "libvirt_volume" "ubuntu_20_04" {
  name   = "ubuntu_20_04"
  pool   = libvirt_pool.base.name
  source = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img"
}

resource "libvirt_network" "k3s_network" {
  name = "br0"
  mode = "bridge"
  bridge = var.bridge_name
  autostart = true
}

module "k3s_cluster" {
  source = "./modules/cluster"

  name = "k3s"

  base_volume = libvirt_volume.ubuntu_20_04
  storage_pool = libvirt_pool.default
  boot_volume_size = 50000000000

  pv_storage_pool = libvirt_pool.longhorn
  pv_volume_size = 300000000000

  sudo_password       = var.sudo_password
  k3s_token           = var.k3s_token
  k3s_master_hostname = var.k3s_master_hostname

  network_bridge = libvirt_network.k3s_network

  ips = [
    "10.2.1.10",
    "10.2.1.11",
    "10.2.1.12",
  ]

  macs = [
    "92:2F:BA:CA:04:A9",
    "92:2F:BA:CA:00:F7",
    "92:2F:BA:CA:0D:9C",
  ]

  gpu_guids = [
    "",
    "",
    "88524b2f-6380-42e2-9c92-832c9191f898"
  ]
}

output "ips" {
  value = module.k3s_cluster.ips
}

terraform {
  required_version = ">= 0.12"
}
