#dynamically generate the inventory file for ansible

locals {
  # role -> [ { name, ip } ]  (only roles that actually have instances)
  inventory_groups = {
    for role in distinct([for i in google_compute_instance.node : i.labels.role]) :
    role => [
      for name, i in google_compute_instance.node :
      # use the sanitized instance name (no "_") so it is valid as a Linux
      # hostname / k8s node name, not the underscored for_each key
      { name = i.name, ip = i.network_interface[0].access_config[0].nat_ip, domain =  }
      if i.labels.role == role
    ]
  }
}

resource "local_file" "ansible_inventory" {
  filename        = var.inventory_path
  file_permission = "0644"
  content = templatefile("${path.module}/templates/inventory.tfpl", {
    groups       = local.inventory_groups
    ssh_user     = var.ssh_user
    ssh_key_file = var.ssh_private_key_file
  })
}