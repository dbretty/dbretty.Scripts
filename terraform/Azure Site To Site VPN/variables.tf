variable "environment_tag" {
  type        = string
  description = "Environment Tag"
}

variable "environment_location" {
  type        = string
  description = "Environment Location"
}

variable "environment_name" {
  type        = string
  description = "Environment Name"
}

variable "vnet_address_space" {
  type        = string
  description = "vNet Address Space"
}

variable "dmz_address_space" {
  type        = string
  description = "DMZ Address Space"
}

variable "infrastructure_address_space" {
  type        = string
  description = "Infrastructure Address Space"
}

variable "general_address_space" {
  type        = string
  description = "General Address Space"
}

variable "gateway_address_space" {
  type        = string
  description = "Gateway Address Space"
}

variable "local_address_space" {
  type        = string
  description = "Local Address Space"
}

variable "shared_secret" {
  type        = string
  description = "Shared Secret"
}