#provider configuration env
project_id = "project-a061befe-8762-43fd-b98"
region     = "asia-east2"
zone       = "asia-east2-c"
name       = "setops"

node_groups = {
  ci-cd = {
    count = 1,
    size  = "e2-medium",
    role  = "ci-cd"
  },
  code-quality = {
    count = 1,
    size  = "e2-medium",
    role  = "code-quality"
  },
  artifact-storage = {
    count = 1,
    size  = "e2-medium",
    role  = "artifact-storage"
  }
}

ssh_user   = "theara6574"
ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHqOS882GkYsYDg4TTM1jOXB7P7oA7vOwU/qy2Mzo+PL theara6574@gmail.com"
# Narrow to your IP for least privilege:
# ssh_source_ranges = ["<your.ip>/32"]
# Private key Ansible uses (must match ssh_pubkey):
ssh_private_key_file = "~/.ssh/id_ed25519"

inventory_path = "../ansible/inventory.ini"