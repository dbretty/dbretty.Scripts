#################################################################
#   Variables
#################################################################

variable "dns_forwarder" {
  description = "The IP Address for the DNS Forwarder"
}

variable "reverse_lookups" {
  description = "A comma delimited list of Reverso Lookup Zones '192.168.1.0/24,192.168.2.0/24'"
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
