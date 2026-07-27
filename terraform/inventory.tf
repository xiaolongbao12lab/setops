locals {

  inventory_groups = {
    for role in distinct([for i in google_compute_instance.node : i.labels.role]) :
    role => [
      for name, i in google_compute_instance.node :
      {
        name = i.name
        ip   = i.network_interface[0].access_config[0].nat_ip
      }
      if i.labels.role == role
    ]
  }

  k8s_inventory_groups = {

    kube_control_plane = [
      for name, i in google_compute_instance.node :
      {
        name = i.name
        external_ip = i.network_interface[0].access_config[0].nat_ip
        internal_ip = i.network_interface[0].network_ip
      }
      if i.labels.role == "k8s-master"
    ]


    etcd = [
      for name, i in google_compute_instance.node :
      {
        name = i.name
        external_ip = i.network_interface[0].access_config[0].nat_ip
        internal_ip = i.network_interface[0].network_ip
      }
      if i.labels.role == "k8s-master"
    ]


    kube_node = [
      for name, i in google_compute_instance.node :
      {
        name = i.name
        external_ip = i.network_interface[0].access_config[0].nat_ip
        internal_ip = i.network_interface[0].network_ip
      }
      if i.labels.role == "k8s-worker"
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

resource "local_file" "kubespray_inventory" {

  filename = var.k8s_inventory_path

  file_permission = "0644"

  content = templatefile(
    "${path.module}/templates/kubespray-hosts.yml.tfpl",
    {
      groups = local.k8s_inventory_groups
      ssh_user     = var.ssh_user
      ssh_key_file = var.k8s_ssh_private_key_file
    }
  )
}