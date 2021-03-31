##########################################################
## Configure Custom OU Structure
##########################################################

locals { 
}

resource "ad_ou" "o" { 
    name = "gplinktestOU"
    path = "dc=bretty,dc=lab"
    description = "OU for gplink tests"
    protected = false
}


