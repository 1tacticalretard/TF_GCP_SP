provider "google" {
  #version = "3.5.0"
  credentials = file("~/Terraform/key.json")
  project     = "dulcet-timing-335111"
  region      = "europe-central2"
  zone        = "europe-central2-a"
}

resource "google_compute_address" "static" {
  name   = "vm-public-address"
  region = "europe-central2"
}

resource "google_compute_firewall" "terraform-firewall1" {
  name      = "ssh-http-8080-ingress"
  network   = google_compute_network.vpc_network.name
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080"]

  }
}
resource "google_compute_firewall" "terraform-firewall2" {
  name      = "ssh-http-8080-egress"
  network   = google_compute_network.vpc_network.name
  direction = "EGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080"]

  }
}
resource "google_compute_network" "vpc_network" {
  name = "spetclinic-network"
}
resource "google_compute_instance" "vm_instance" {
  name         = "spring-petclinic"
  machine_type = "f1-micro"
  zone         = "europe-central2-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
  provisioner "file" {
  source      = "~/Terraform/spring-petclinic.service"
  destination = "/home/zheniakushnir7/spring-petclinic.service"
  connection {
    type        = "ssh"
    host        = google_compute_address.static.address
    user        = "zheniakushnir7"
    private_key = file("~/.ssh/yoba")
    agent       = true
  }
}
  provisioner "file" {
  source      = "~/Terraform/service_script.sh"
  destination = "/home/zheniakushnir7/service_script.sh"
  connection {
    type        = "ssh"
    host        = google_compute_address.static.address
    user        = "zheniakushnir7"
    private_key = file("~/.ssh/yoba")
    agent       = true
  }
}
  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/service_script.sh",
      "sudo mv /home/zheniakushnir7/spring-petclinic.service /etc/systemd/system/",
      "sudo apt update",
      "sudo apt install -y default-jre default-jdk maven",
      "git clone https://github.com/spring-projects/spring-petclinic.git",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable spring-petclinic.service",
      "sudo systemctl start spring-petclinic",
    ]
    connection {
      type        = "ssh"
      host        = google_compute_address.static.address
      user        = "zheniakushnir7"
      private_key = file("~/.ssh/yoba")
      agent       = true
    }
  }




}

