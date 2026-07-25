locals {
  instance_domains = {
    for k, v in local.instances :
    k => {
      name = "${v.domain}"
    }
    if v.is_create_domain
  }
}

resource "cloudflare_dns_record" "dns_instance" {
  for_each = local.instance_domains

  zone_id = var.cf_zone_id
  name    = each.value.name
  type    = "A"
  content = google_compute_instance.node[each.key].network_interface[0].access_config[0].nat_ip
  ttl     = 300
  proxied = false

  depends_on = [
    google_compute_instance.node
  ]
}