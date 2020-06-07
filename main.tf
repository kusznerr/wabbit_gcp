provider "google" {
  //credentials = "${file("account.json")}" -> Setup in GOOGLE_CREDENTIALS veriable (remove newline)
  project     = var.project 
  region      = "europe-west3"
  zone        = "europe-west3-c"
}

resource "google_compute_instance" "vm_instance" {
  name         = "www40"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network       = google_compute_network.vpc_network.self_link
    access_config {
    }
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = "true"
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
    ports    = ["80", "8080", "443", "7443" , "1935"]
  }


  //source_tags = ["wabbit_bbb"]
}
