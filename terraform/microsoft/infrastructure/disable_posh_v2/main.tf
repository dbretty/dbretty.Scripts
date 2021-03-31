##########################################################
## Disable PowerShell v2
##########################################################

locals { 
  disable_posh_command = "Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2"
  powershell_command   = "${local.disable_posh_command}"
}

resource "null_resource" "disable_posh_v2" {
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
