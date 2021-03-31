##########################################################
## Configure Custom OU Structure
##########################################################

locals { 
  script_file   = "https://raw.githubusercontent.com/dbretty/bretty.lab/master/scripts/configure_ou_structure.ps1"
  out_file      = "C:/Windows/Temp/configure_ou_structure.ps1"
}

resource "null_resource" "configure_ou_structure" {

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
      "powershell -File ${local.out_file} -root_ou \"${var.root_ou}\" -lab_name \"${var.lab_name}\"",
      "powershell -Command \"Remove-Item -Path ${local.out_file} -Force\"",

    ]
  }
}