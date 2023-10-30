/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# [START cloudvpn_ha_gcp_to_gcp]

 ############################################# 
 # Create TWO VPC and Subnets in Two Projects 
 #############################################

resource "google_compute_network" "network1" {
  name                   = var.network1_name
  project       = var.project_id
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

resource "google_compute_network" "network2" {
  name                    = var.network2_name
  routing_mode            = "GLOBAL"
  project       = var.project_id_02
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "network1_subnet1" {
  name          =  var.network1_subnet1_name                #"ha-vpn-subnet-1"
  project       = var.project_id
  ip_cidr_range = "10.0.1.0/24"
  region        = "asia-south1"
  network       = google_compute_network.network1.id
}

resource "google_compute_subnetwork" "network1_subnet2" {
  name          =  var.network1_subnet2_name      #"ha-vpn-subnet-2"
  project       = var.project_id
  ip_cidr_range = "10.0.2.0/24"
  region        = "asia-south2"
  network       = google_compute_network.network1.id
}

resource "google_compute_subnetwork" "network2_subnet1" {
  name          = var.network2_subnet1_name   #"ha-vpn-subnet-3"
  project       = var.project_id_02
  ip_cidr_range = "192.168.1.0/24"
  region        = "asia-south1"
  network       = google_compute_network.network2.id
}

resource "google_compute_subnetwork" "network2_subnet2" {
  name          = var.network2_subnet2_name    #"ha-vpn-subnet-4"
  project       = var.project_id_02
  ip_cidr_range = "192.168.2.0/24"
  region        = "asia-south2"
  network       = google_compute_network.network2.id
}

module "firewall_rules_project01" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  //depends_on = [module.vpc]
  project_id   = var.project_id
  network_name = google_compute_network.network1.id
  //count         =  length(var.internal_allow) > 0 ? 1 : 0
  rules = [

    for r in var.rules_01 : {
      name                    = r.name
      description             = r.description
      direction               = r.direction
      priority                = r.priority
      ranges                  = r.ranges
      source_tags             = r.source_tags
      source_service_accounts = r.source_service_accounts
      target_tags             = r.target_tags
      target_service_accounts = r.target_service_accounts
      allow                   = r.allow
      deny                    = r.deny
      log_config              = r.log_config
  }]
}
/*
resource "google_compute_firewall" "firewall_ssh_01" {
  name    = "test-firewall-01"
  project       = var.project_id
  network = google_compute_network.network1.id
  depends_on = [module.firewall_rules_project01]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }

  source_tags = ["web"]
}

resource "google_compute_firewall" "firewall_ssh_02" {
  name    = "test-firewall-02"
  project       = var.project_id_02
  network = google_compute_network.network2.id
  depends_on = [ module.firewall_rules_project02 ]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }

  source_tags = ["web"]
}
*/

module "firewall_rules_project02" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  //depends_on = [module.vpc]
  project_id   = var.project_id_02
  network_name = google_compute_network.network2.id
   //count         =  length(var.internal_allow) > 0 ? 1 : 0
  rules = [

    for r in var.rules_02 : {
      name                    = r.name
      description             = r.description
      direction               = r.direction
      priority                = r.priority
      ranges                  = r.ranges
      source_tags             = r.source_tags
      source_service_accounts = r.source_service_accounts
      target_tags             = r.target_tags
      target_service_accounts = r.target_service_accounts
      allow                   = r.allow
      deny                    = r.deny
      log_config              = r.log_config
  }]
}
########################## 
# Create HA-VPN Gateway 
##########################

resource "google_compute_ha_vpn_gateway" "ha_gateway1" {
  region  = "asia-south2"
  project       = var.project_id
  name    = "ha-vpn-1"
  network = google_compute_network.network1.id
}

resource "google_compute_ha_vpn_gateway" "ha_gateway2" {
  region  = "asia-south2"
  project       = var.project_id_02
  name    = "ha-vpn-2"
  network = google_compute_network.network2.id
}



#################################### 
 # Create Cloud Router for Both VPC 
####################################

resource "google_compute_router" "router1" {
  name    = "ha-vpn-router1"
  project       = var.project_id
  region  = "asia-south2"
  network = google_compute_network.network1.name
  bgp {
    asn = 64514
  }
}

resource "google_compute_router" "router2" {
  name    = "ha-vpn-router2"
  project       = var.project_id_02
  region  = "asia-south2"
  network = google_compute_network.network2.name
  bgp {
    asn = 64515
  }
}


################################################################## 
# Create pair of Tunnel on each Interface such as Interface 0, 1 
##################################################################

resource "google_compute_vpn_tunnel" "tunnel1" {
  name                  = "ha-vpn-tunnel1"
  project       = var.project_id
  region                = "asia-south2"
  vpn_gateway           = google_compute_ha_vpn_gateway.ha_gateway1.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.ha_gateway2.id
  shared_secret         = var.shared_secret
  router                = google_compute_router.router1.id
  vpn_gateway_interface = 0
}

resource "google_compute_vpn_tunnel" "tunnel2" {
  name                  = "ha-vpn-tunnel2"
  project       = var.project_id
  region                = "asia-south2"
  vpn_gateway           = google_compute_ha_vpn_gateway.ha_gateway1.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.ha_gateway2.id
  shared_secret         = var.shared_secret
  router                = google_compute_router.router1.id
  vpn_gateway_interface = 1
}

resource "google_compute_vpn_tunnel" "tunnel3" {
  name                  = "ha-vpn-tunnel3"
  project       = var.project_id_02
  region                = "asia-south2"
  vpn_gateway           = google_compute_ha_vpn_gateway.ha_gateway2.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.ha_gateway1.id
  shared_secret         = var.shared_secret
  router                = google_compute_router.router2.id
  vpn_gateway_interface = 0
}

resource "google_compute_vpn_tunnel" "tunnel4" {
  name                  = "ha-vpn-tunnel4"
  project       = var.project_id_02
  region                = "asia-south2"
  vpn_gateway           = google_compute_ha_vpn_gateway.ha_gateway2.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.ha_gateway1.id
  shared_secret         = var.shared_secret
  router                = google_compute_router.router2.id
  vpn_gateway_interface = 1
}



######################################## 
# Configure BGP session at each tunnel 
########################################

resource "google_compute_router_interface" "router1_interface1" {
  name       = "router1-interface1"
  project       = var.project_id
  router     = google_compute_router.router1.name
  region     = "asia-south2"
  ip_range   = "169.254.0.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel1.name
}

resource "google_compute_router_peer" "router1_peer1" {
  name                      = "router1-peer1"
  project       = var.project_id
  router                    = google_compute_router.router1.name
  region                    = "asia-south2"
  peer_ip_address           = "169.254.0.2"
  peer_asn                  = 64515
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.router1_interface1.name
}

resource "google_compute_router_interface" "router1_interface2" {
  name       = "router1-interface2"
  project       = var.project_id
  router     = google_compute_router.router1.name
  region     = "asia-south2"
  ip_range   = "169.254.1.2/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel2.name
}

resource "google_compute_router_peer" "router1_peer2" {
  name                      = "router1-peer2"
  project       = var.project_id
  router                    = google_compute_router.router1.name
  region                    = "asia-south2"
  peer_ip_address           = "169.254.1.1"
  peer_asn                  = 64515
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.router1_interface2.name
}

resource "google_compute_router_interface" "router2_interface1" {
  name       = "router2-interface1"
  project       = var.project_id_02
  router     = google_compute_router.router2.name
  region     = "asia-south2"
  ip_range   = "169.254.0.2/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel3.name
}

resource "google_compute_router_peer" "router2_peer1" {
  name                      = "router2-peer1"
  project       = var.project_id_02
  router                    = google_compute_router.router2.name
  region                    = "asia-south2"
  peer_ip_address           = "169.254.0.1"
  peer_asn                  = 64514
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.router2_interface1.name
}

resource "google_compute_router_interface" "router2_interface2" {
  name       = "router2-interface2"
  project       = var.project_id_02
  router     = google_compute_router.router2.name
  region     = "asia-south2"
  ip_range   = "169.254.1.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel4.name
}

resource "google_compute_router_peer" "router2_peer2" {
  name                      = "router2-peer2"
  project       = var.project_id_02
  router                    = google_compute_router.router2.name
  region                    = "asia-south2"
  peer_ip_address           = "169.254.1.2"
  peer_asn                  = 64514
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.router2_interface2.name
}
# [END cloudvpn_ha_gcp_to_gcp]