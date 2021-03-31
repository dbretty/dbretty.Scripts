##########################################################
## Configure WSUS on a Server
##########################################################

locals { 
  script_file   = "https://raw.githubusercontent.com/dbretty/bretty.lab/master/scripts/configure_wsus.ps1"
  out_file      = "C:/Windows/Temp/configure_wsus.ps1"
}

resource "null_resource" "configure_wsus" {

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
      "powershell -Command \"Invoke-WebRequest -Uri ${local.script_file} -OutFile ${local.out_file}\"",
      "powershell -File ${local.out_file}",
      "powershell -Command \"Remove-Item -Path ${local.out_file} -Force\"",
    ]
  }
}