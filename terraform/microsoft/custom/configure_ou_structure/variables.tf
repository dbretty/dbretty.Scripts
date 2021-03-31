#################################################################
#   Variables
#################################################################

variable "root_ou" {
  description = "The Root DC for the Domain 'DC=bretty,DC=lab'"
}

variable "lab_name" {
  description = "The Name you want for the top level OU for the lab"
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
