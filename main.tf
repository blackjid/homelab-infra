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

resource "libvirt_volume" "ubuntu_18_04" {
  name   = "ubuntu_18_04"
  pool   = libvirt_pool.base.name
  source = "https://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-amd64.img"
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
  size = 3

  base_volume = libvirt_volume.ubuntu_18_04
  storage_pool = libvirt_pool.default
  boot_volume_size = 21474836480
  ceph_volume_size = 75161927680

  ssh_authorized_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGRyQJ2V+aljTD/SZp7CKpmwkyO47A+WXq4LpyQlknJY jidonoso@black-mac.lan"]
  network_bridge = libvirt_network.k3s_network
}

output "ips" {
  value = module.k3s_cluster.ips
}

terraform {
  required_version = ">= 0.12"
}
