#################################################################
#   Variables
#################################################################

variable "dns_server" {
  description = "The DNS Server to use for the Server DHCP Options"
}

variable "gateway" {
  description = "The Gateway Server to use for the Server DHCP Options"
}

variable "admin_username" {
  description = "The username associated with the local administrator account on the virtual machine"
}

variable "admin_password" {
  description = "The password associated with the local administrator account on the virtual machine"
}

variable "host_name" {
  description = "The hostname for the virtual machine"
}

variable "scope_name" {
  description = "The Name for the DHCP Scope"
}

variable "scope_network" {
  description = "The Overall Network for the DHCP Scope '192.168.10.0'"
}

variable "start_address" {
  description = "The Start Address for the DHCP Scope '192.168.10.100'"
}

variable "end_address" {
  description = "The End Address for the DHCP Scope '192.168.10.200'"
}

variable "subnet_mask" {
  description = "The Subnet Mask for the DHCP Scope '255.255.255.0'"
}
