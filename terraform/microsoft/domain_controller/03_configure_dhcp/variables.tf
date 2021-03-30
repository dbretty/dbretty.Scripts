#################################################################
#   Variables
#################################################################

variable "dns_server" {
  description = "The name of the Active Directory domain, for example `consoto.local`"
}

variable "gateway" {
  description = "The name of the Active Directory domain, for example `consoto.local`"
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
