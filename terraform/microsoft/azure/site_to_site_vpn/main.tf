provider "azurerm" {
  features {}
}

  # Resource Group For Infrastructure
  resource "azurerm_resource_group" "infrastructure_resource_group" {
    name     = "rgrp_${var.environment_name}_infrastructure"
    location = var.environment_location
    tags = {
      Environment = var.environment_tag
    }
  }

  # Virtual Networks and Subnets

  # Add Outer vNet
  resource "azurerm_virtual_network" "lab_vnet" {
    name                = "vnet_${var.environment_name}"
    location            = var.environment_location
    resource_group_name = azurerm_resource_group.infrastructure_resource_group.name
    address_space       = [var.vnet_address_space]
    dns_servers         = ["8.8.8.8"]
    tags = {
      Environment = var.environment_tag
    }
  }

  # Add Outer Subnets
  resource "azurerm_subnet" "gateway_subnet" {
    name                 = "GatewaySubnet"
    resource_group_name  = azurerm_resource_group.infrastructure_resource_group.name
    virtual_network_name = azurerm_virtual_network.lab_vnet.name
    address_prefixes     = [var.gateway_address_space]
  }

  # Add Outer Subnets
  resource "azurerm_subnet" "dmz_subnet" {
    name                 = "sub_${var.environment_name}_dmz"
    resource_group_name  = azurerm_resource_group.infrastructure_resource_group.name
    virtual_network_name = azurerm_virtual_network.lab_vnet.name
    address_prefixes     = [var.dmz_address_space]
  }

  resource "azurerm_subnet" "infrastructure_subnet" {
    name                 = "sub_${var.environment_name}_infrastructure"
    resource_group_name  = azurerm_resource_group.infrastructure_resource_group.name
    virtual_network_name = azurerm_virtual_network.lab_vnet.name
    address_prefixes     = [var.infrastructure_address_space]
  }

  resource "azurerm_subnet" "general_subnet" {
    name                 = "sub_${var.environment_name}_general"
    resource_group_name  = azurerm_resource_group.infrastructure_resource_group.name
    virtual_network_name = azurerm_virtual_network.lab_vnet.name
    address_prefixes     = [var.general_address_space]
  }

  resource "azurerm_public_ip" "gateway_pip" {
  name                = "pip_${var.environment_name}_gateway"
  location            = azurerm_resource_group.infrastructure_resource_group.location
  resource_group_name = azurerm_resource_group.infrastructure_resource_group.name
  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "cld_gateway" {
  name                = "cld_${var.environment_name}_gateway"
  location            = azurerm_resource_group.infrastructure_resource_group.location
  resource_group_name = azurerm_resource_group.infrastructure_resource_group.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.gateway_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet.id
  }
    
}

# Get Client IP Address for NSG
  data "http" "clientip" {
    url = "https://ipv4.icanhazip.com/"
  }
  
resource "azurerm_local_network_gateway" "lcl_gateway" {
  name                = "lcl_${var.environment_name}_gateway"
  resource_group_name = azurerm_resource_group.infrastructure_resource_group.name
  location            = azurerm_resource_group.infrastructure_resource_group.location
  gateway_address     = "${chomp(data.http.clientip.body)}"
  address_space       = ["${var.local_address_space}"]
}

resource "azurerm_virtual_network_gateway_connection" "conn_s2s_vpn" {
    name                       = "connect_${var.environment_name}_s2s_vpn"
    location                   = azurerm_resource_group.infrastructure_resource_group.location
    resource_group_name        = azurerm_resource_group.infrastructure_resource_group.name
    type                       = "IPsec"
    virtual_network_gateway_id = azurerm_virtual_network_gateway.cld_gateway.id
    local_network_gateway_id   = azurerm_local_network_gateway.lcl_gateway.id
    shared_key                 = "${var.shared_secret}"
}