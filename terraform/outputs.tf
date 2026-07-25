# Outputs consumed by the configuration layer (Ansible).

# name -> { role, internal_ip, external_ip }
output "instances" {
  description = "Provisioned instances keyed by name, with role and IPs"
  value = {
    for name, inst in google_compute_instance.node :
    name => {
      role        = inst.labels.role
      internal_ip = inst.network_interface[0].network_ip
      external_ip = inst.network_interface[0].access_config[0].nat_ip
    }
  }
}

# role -> [external_ip, ...]  (handy for static inventory / sanity checks)
output "instances_by_role" {
  description = "External IPs grouped by role"
  value = {
    for role in distinct([for inst in google_compute_instance.node : inst.labels.role]) :
    role => [
      for inst in google_compute_instance.node :
      inst.network_interface[0].access_config[0].nat_ip
      if inst.labels.role == role
    ]
  }
}

output "instance_domains" {
  value = {
    for k, record in cloudflare_dns_record.dns_instance :
    google_compute_instance.node[k].name => "${record.name}.${var.cf_domain}"
  }
}