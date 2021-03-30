##########################################################
## Promote VM to be a Domain Controller
##########################################################

locals { 
}

resource "null_resource" "domain_controller" {

  provisioner "file" {
    source = "./configure_wsus.ps1"
    destination = "C:/Windows/Temp/configure_wsus.ps1"
    
    connection {
      type      = "winrm"
      user      = var.admin_username
      password  = var.admin_password
      insecure  = "true"
      https     = "true"
      host      = var.host_name
    }
    
  }
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
      "powershell -File C:/Windows/Temp/configure_wsus.ps1",
    ]
}
}




