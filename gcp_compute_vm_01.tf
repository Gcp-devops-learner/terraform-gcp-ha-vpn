resource "google_compute_instance" "vpn_server-01" {
    name         = "${var.prefix}-vpn-server-01"
    project       = var.project_id
    machine_type = "e2-small"
    zone         = "asia-south1-c"
    can_ip_forward = true
    
    tags = [
        "vpn-server-01"
    ]
    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-10"
            size = 20
            }
        }

    network_interface {
        network = google_compute_network.network1.id
        subnetwork = google_compute_subnetwork.network1_subnet1.id
    }
}