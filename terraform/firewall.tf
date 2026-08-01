# Firewall rules for the cluster nodes (on the "default" network).

# Allow SSH only from the approved source ranges.
resource "google_compute_firewall" "ssh" {
  name    = "${var.name}-allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_source_ranges
  target_tags   = ["ssh"]
}

# Allow HTTP/HTTPS for instances that get a public domain + certbot cert.
resource "google_compute_firewall" "web" {
  name    = "${var.name}-allow-web"
  network = "default"

  direction = "INGRESS"

  target_tags = ["http-server"]

  source_ranges = [
    "0.0.0.0/0"
  ]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

# Allow unrestricted traffic between cluster nodes (node-to-node / pod
# networking).
resource "google_compute_firewall" "internal" {
  name    = "${var.name}-allow-internal"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_tags = ["ssh"]
  target_tags = ["ssh"]
}

# Allow ports for some service UI (Jenkins, Sonarqube, Nexus, ...)
locals {
  ui_ports = {
    ci-cd            = ["8080", "9443"]         # Jenkins
    artifact-storage = ["8081", "8082", "9443"] # Nexus UI + Docker Registry
    code-quality     = ["9000", "9443"]         # SonarQube
    k8s-master       = ["6443", "9443"]         # k8s
  }
}

resource "google_compute_firewall" "service_ui" {
  for_each = local.ui_ports

  name    = "allow-service-ui-${each.key}"
  network = "default"

  direction = "INGRESS"

  target_tags = [each.key]

  source_ranges = [
    "0.0.0.0/0"
  ]

  allow {
    protocol = "tcp"
    ports    = each.value
  }
}