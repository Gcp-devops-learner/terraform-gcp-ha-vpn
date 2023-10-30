project_id = "km1-runcloud"

project_id_02 = "service-project1-367504"

network1_name = "network1"

network2_name = "network2"

network1_subnet1_name = "ha-vpn-subnet-1"

network1_subnet2_name = "ha-vpn-subnet-2"

network2_subnet1_name = "ha-vpn-subnet-3"

network2_subnet2_name = "ha-vpn-subnet-4"

shared_secret = "test@123"

rules_01 = [{
    name                    = "firewall-allow-ssh-ingress"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["0.0.0.0/0"]  #["0.0.0.0/0", "192.168.1.0/24","35.235.240.0/20"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = [{
    protocol = "all"
    ports    = []
    }]
    /*
    allow = [{
      protocol = "tcp"
      ports    = ["22"]
    }]
  */
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }]

  rules_02 = [{
    name                    = "firewall-allow-ssh-ingress"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["0.0.0.0/0"]  #["0.0.0.0/0", "10.0.1.0/24","35.235.240.0/20"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = [{
    protocol = "all"
    ports    = []
    }]
    /*
    allow = [{
      protocol = "tcp"
      ports    = ["22"]
    }]
    */
    
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }]

