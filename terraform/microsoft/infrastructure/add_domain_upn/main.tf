##########################################################
## Add additional UPN to Domain
##########################################################

locals { 
}

resource "null_resource" "configure_domain" {
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
      "powershell -Command \"Get-ADForest | Set-ADForest -UPNSuffixes @{add='${var.upn}'}\"",
    ]
  }
}
