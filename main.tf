provider "google" {
  //credentials = "${file("account.json")}" -> Setup in GOOGLE_CREDENTIALS veriable (remove newline)
  project     = var.project 
  region      = var.region
}

resource "google_compute_address" "test-static-ip-address" {
 count  = var.gcp_vm_count
 name   = "${var.project}-wabbit-external-ip-${var.wabbitwww}${count.index}"
 region = var.region
 }

 resource "google_compute_address" "internal_ip" {
  count  = var.gcp_vm_count
  name         = "${var.wabbitwww}${count.index}-internal-address"
  address_type = "INTERNAL"
  //network       = google_compute_network.vpc_network.self_link
  region       = var.region
  subnetwork       = google_compute_subnetwork.wabbit-subnet.self_link
}

resource "google_compute_instance" "bbb_instance" {
  count        = var.gcp_vm_count
  name         = "${var.wabbitwww}${count.index}"
  zone        = var.zone
  //machine_type = "f1-micro"
  //machine_type = "n2-standard-8"
  machine_type = "n1-standard-8"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    subnetwork       = google_compute_subnetwork.wabbit-subnet.self_link
    network_ip = google_compute_address.internal_ip[count.index].address
    access_config {
      nat_ip = google_compute_address.test-static-ip-address[count.index].address
    }
  }
}

?*
resource "google_compute_instance" "nomad_instance" {
  //count        = var.gcp_vm_count
  name         = "nomad-${var.wabbitwww}"
  zone        = var.zone
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }
  
  network_interface {
    # A default network is created for all GCP projects
    subnetwork       = google_compute_subnetwork.wabbit-subnet.self_link
    access_config {
      }
  }
}
*/
resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "wabbit-subnet" {
  name    = "${var.network_name}-subnet"
  ip_cidr_range = var.wabbit_cidr_range
  region = var.region
  network = google_compute_network.vpc_network.self_link
}

// VPC peering to wabbit main project

resource "google_compute_network_peering" "peer_to_wabbit" {
  name         = "peering${var.wabbitwww}"
  network      = google_compute_network.vpc_network.self_link
  peer_network = "projects/wabbit/global/networks/klasa-vpc"
}



resource "google_compute_firewall" "wabbit_fw" {
  name    = "wabbit-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "udp"
    ports = ["16384-32768"]
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "443", "7443" , "1935" , "22"]
  }


  //source_tags = ["wabbit_bbb"]
}
