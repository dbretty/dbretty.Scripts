#################################################################
#   Variables
#################################################################

variable "admin_username" {
  description = "The username associated with the local administrator account on the virtual machine"
}

variable "admin_password" {
  description = "The password associated with the local administrator account on the virtual machine"
}

variable "host_name" {
  description = "The hostname for the virtual machine"
}

variable "upn" {
  description = "The UPN you wish to add"
}