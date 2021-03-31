##########################################################
## Disable SMB 1
##########################################################

locals { 
  disable_smb_command = "Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force"
  powershell_command   = "${local.disable_smb_command}"
}

resource "null_resource" "disable_smb_v1" {
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
