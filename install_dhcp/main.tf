##########################################################
## Promote VM to be a Domain Controller
##########################################################

locals { 
  install_dhcp_command   = "Install-WindowsFeature DHCP"
  exit_code_hack       = "exit 0"
  powershell_command   = "${local.install_dhcp_command}; ${local.exit_code_hack}"
}

resource "null_resource" "dhcp_install" {
  provisioner "remote-exec" {
    connection {
      type      = "winrm"
      user      = var.admin_username
      password  = var.admin_password
      insecure  = "true"
      https     = "true"
      host      = var.host_name
    }
    inline = [
      "powershell -Command \"${local.powershell_command}\"",
    ]
}
}
