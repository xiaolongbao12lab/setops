variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-east2"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "asia-east2-c"
}

variable "name" {
  description = "Name for the instance and firewall rules"
  type        = string
  default     = "demo-web"
}

variable "node_groups" {
  description = "Map of node groups for this environment"
  type = map(object({
    count     = number
    size      = string
    role      = string
    stateful  = optional(bool, false)
    volume_gb = optional(number, 0)
  }))
}

variable "ssh_user" {
  description = "Linux user provisioned for SSH access"
  type        = string
}

variable "ssh_pubkey" {
  description = "Public key contents for ssh_user"
  type        = string
}

variable "ssh_source_ranges" {
  description = "CIDR ranges allowed to reach instances over SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_private_key_file" {
  description = "Path to the SSH private key Ansible uses to reach instances"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "inventory_path" {
  description = "Filesystem path where the generated Ansible inventory is written"
  type        = string
}