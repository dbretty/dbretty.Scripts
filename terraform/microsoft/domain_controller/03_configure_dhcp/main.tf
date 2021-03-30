##########################################################
## Configure and Install DHCP on a server
##########################################################

locals { 
  script_file   = "https://github.com/dbretty/bretty.lab/blob/master/scripts/configure_dhcp.ps1"
  out_file   = "C:/Windows/Temp/configure_dhcp.ps1"
}

resource "null_resource" "bretty.lab_configure_dhcp" {

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
      "powershell -Command \"Invoke-WebRequest -Uri ${local.script_file} -OutFile ${var.out_file}\"",
      "powershell -File ${var.out_file} -DNSServer ${var.dns_server} -Gateway ${var.gateway} -Verbose",
      "powershell -Command \"Remove-Item -Path ${var.out_file} -Force\"",
    ]
  }
}