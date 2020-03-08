variable "name" {
  type = string
}

variable "size" {
  type = number
  default = 1
}

variable "ssh_authorized_keys" {
  type = list(string)
  default = []
}

variable "base_volume" {

}

variable "storage_pool" {
}

variable "boot_volume_size" {
  type = number
  default = 10737418240
  description = "Default to 10GB"
}

variable "ceph_volume_size" {
  type = number
  default = 107374182400
  description = "Default to 100GB"
}

variable "network_bridge" {
  type = object({ name=string })
}
