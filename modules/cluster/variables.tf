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

variable "pv_volume_size" {
  type = number
  default = 107374182400
  description = "Default to 100GB"
}

variable "pv_storage_pool" {
}

variable "network_bridge" {
  type = object({ name=string })
}

variable "ips" {
  type = list(string)
  default = []
}

variable "macs" {
  type = list(string)
  default = []
}

variable "gpu_guids" {
  type = list(string)
  default = []
}

variable "sudo_password" {
  type = string
}

variable "k3s_token" {
  type = string
}

variable "k3s_master_hostname" {
  type = string
}