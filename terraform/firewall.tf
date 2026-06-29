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
