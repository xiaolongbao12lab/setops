resource "cloudflare_dns_record" "dns_instance" {
  for_each = local.instance_domains

  zone_id = var.cf_zone_id
  name = each.value
  type = "A"
  content = google_compute_instance.node[each.key].network_interface[0].access_config[0].nat_ip
  ttl = 300
  proxied = false

  depends_on = [ 
    google_compute_instance.node 
  ]
}