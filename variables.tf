variable "virt_host" {
    type = string
}

variable "bridge_name" {
    type = string
    default = "br0"
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