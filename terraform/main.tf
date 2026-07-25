data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

# Expand each node group's `count` into individual instances.
# Stable key per instance: "<group>-<index>".
locals {
  instances = merge([
    for name, cfg in var.node_groups : {
      for i in range(cfg.count) :
      "${name}-${i}" => {
        group            = name
        role             = cfg.role
        size             = cfg.size
        domain           = coalesce(cfg.domain, cfg.role)
        is_create_domain = cfg.is_create_domain
      }
    }
  ]...)
}

resource "google_compute_instance" "node" {
  for_each = local.instances

  name         = "${var.name}-${each.key}"
  machine_type = each.value.size
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
    }
  }

  network_interface {
    network = "default"
    access_config {

    }
  }

  labels = {
    role = each.value.role
  }

  tags = ["ssh", "http-server", "${each.value.role}"]

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_pubkey}"
  }
}