##########################################################
## Configure DHCP Scope on Server
##########################################################

locals { 
  script_file   = "https://raw.githubusercontent.com/dbretty/bretty.lab/master/scripts/configure_dhcp_scope.ps1"
  out_file      = "C:/Windows/Temp/configure_dhcp_scope.ps1"
}

resource "null_resource" "configure_dhcp_scope" {

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
      "powershell -File ${local.out_file} -dns_server ${var.dns_server} -gateway ${var.gateway} -scope_name ${var.scope_name} -scope_network ${var.scope_network} -start_address ${var.start_address} -end_address ${var.end_address} -subnet_mask ${var.subnet_mask}",
      "powershell -Command \"Remove-Item -Path ${local.out_file} -Force\"",
    ]
  }
}
