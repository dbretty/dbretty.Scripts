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
  description = "The hostname for the server"
}
