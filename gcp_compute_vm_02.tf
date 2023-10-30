resource "google_compute_instance" "vpn_server-02" {
    name         = "${var.prefix}-vpn-server-02"
    project       = var.project_id_02
    machine_type = "e2-small"
    zone         = "asia-south1-c"
    can_ip_forward = true
    
    tags = [
        "vpn-server-02"
    ]
    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-10"
            size = 20
            }
        }

    network_interface {
        network = google_compute_network.network2.id
        subnetwork = google_compute_subnetwork.network2_subnet1.id
    }
}
