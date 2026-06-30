# setops

Infrastructure-as-code to provision Ubuntu VMs on **Google Cloud** with **Terraform**
and configure a DevOps toolchain on them with **Ansible**.

Terraform creates the instances and firewall rules, then writes an Ansible
inventory. Ansible takes over and installs the baseline (Docker, Portainer,
shell tooling) plus a CI/CD stack (Jenkins, GitHub CLI). Additional roles for
Nexus and SonarQube ship in the repo.

---

## Architecture

```
                 terraform apply                 ansible-playbook site.yml
   variables  ─────────────────►  GCP VMs  ─────────────────────────────►  configured hosts
 (tfvars)        + firewall          │         baseline + ci-cd roles
                                     │
                          generated inventory.ini
                          (consumed by Ansible)
```

- **Terraform** ([terraform/](terraform/)) — provisions `google_compute_instance`
  nodes from a `node_groups` map, applies firewall rules, and renders an Ansible
  inventory from [templates/inventory.tfpl](terraform/templates/inventory.tfpl).
- **Ansible** ([ansible/](ansible/)) — applies roles to the provisioned hosts,
  grouped by the `role` label each node carries.

---

## Prerequisites

| Tool        | Version    | Notes                                              |
| ----------- | ---------- | -------------------------------------------------- |
| Terraform   | >= 1.5.0   | Provider versions pinned in `.terraform.lock.hcl`  |
| Ansible     | >= 2.15    | Plus collections from `requirements.yml`           |
| gcloud SDK  | latest     | For authentication (ADC)                           |
| SSH keypair | ed25519    | Public key goes in tfvars; private key drives SSH  |

Authenticate to GCP with Application Default Credentials before running Terraform:

```bash
gcloud auth application-default login
```

---

## Quick start

### 1. Provision infrastructure (Terraform)

```bash
cd terraform

# Configure your environment
cp terraform.tfvars.example terraform.tfvars
$EDITOR terraform.tfvars        # set project_id, ssh_pubkey, node_groups, inventory_path, ...

terraform init
terraform plan
terraform apply
```

This creates the VMs, the firewall rules, and writes the Ansible inventory to
the `inventory_path` you set in tfvars.

### 2. Configure the hosts (Ansible)

```bash
cd ../ansible

ansible-galaxy collection install -r requirements.yml
ansible-playbook site.yml
```

`site.yml` runs:
1. **baseline** ([playbooks/baseline.yml](ansible/playbooks/baseline.yml)) — `common`, `oh-my-zsh`, `docker`, `portainer` on every host.
2. **ci-cd** ([playbooks/ci-cd.yml](ansible/playbooks/ci-cd.yml)) — `gh`, `jenkins` on hosts in the `ci-cd` group.

---

## Configuration

### Terraform variables ([variables.tf](terraform/variables.tf))

| Variable               | Required | Default              | Description                                          |
| ---------------------- | -------- | -------------------- | ---------------------------------------------------- |
| `project_id`           | yes      | —                    | GCP project ID                                       |
| `region` / `zone`      | no       | `asia-east2[-c]`     | Where instances are created                          |
| `name`                 | no       | `demo-web`           | Prefix for instance and firewall names               |
| `node_groups`          | yes      | —                    | Map of groups → `{ count, size, role }`              |
| `ssh_user`             | yes      | —                    | Linux user provisioned for SSH                       |
| `ssh_pubkey`           | yes      | —                    | Public key contents for `ssh_user`                   |
| `ssh_source_ranges`    | no       | `0.0.0.0/0`          | CIDRs allowed to reach SSH (**narrow this**)         |
| `ssh_private_key_file` | no       | `~/.ssh/id_ed25519`  | Private key Ansible uses                              |
| `inventory_path`       | yes      | —                    | Where the generated Ansible inventory is written     |

**`node_groups`** drives everything. Each group produces `count` instances named
`<name>-<group>-<index>`, labelled with `role`. The `role` becomes the Ansible
inventory group, so it must match the `hosts:` targets in the playbooks
(e.g. `ci-cd`).

```hcl
node_groups = {
  ci-cd = { count = 1, size = "e2-medium", role = "ci-cd" }
}
```

### Firewall ([firewall.tf](terraform/firewall.tf))

- `allow-ssh` — port 22 from `ssh_source_ranges`, to nodes tagged `ssh`.
- `allow-internal` — node-to-node traffic between cluster members.
- `allow-service-ui-*` — service UIs by role tag: Jenkins `8080`, Nexus `8081/8082`,
  SonarQube `9000`, Portainer `9443`.

---

## Available Ansible roles

| Role         | Purpose                                          |
| ------------ | ------------------------------------------------ |
| `common`     | Timezone, security updates, baseline packages    |
| `oh-my-zsh`  | Shell setup                                       |
| `docker`     | Docker engine                                     |
| `portainer`  | Container management UI (`:9443`)                 |
| `gh`         | GitHub CLI                                        |
| `jenkins`    | Jenkins + Java (`:8080`)                          |
| `nexus-oss`  | Nexus repository manager (`:8081`)               |
| `sonarqube`  | SonarQube code quality (`:9000`)                 |

> `nexus-oss` and `sonarqube` roles exist but are not yet wired into `site.yml`.

---

## Repository layout

```
terraform/
  versions.tf      provider requirements + version constraints
  providers.tf     google provider config
  variables.tf     input variables
  main.tf          compute instances (from node_groups)
  firewall.tf      firewall rules
  inventory.tf     renders the Ansible inventory (local_file)
  outputs.tf       instances + IPs by role
  templates/       inventory.tfpl
ansible/
  ansible.cfg      inventory path, defaults
  requirements.yml Galaxy collections
  site.yml         top-level playbook
  playbooks/       baseline.yml, ci-cd.yml
  roles/           common, docker, jenkins, nexus-oss, sonarqube, ...
```

---

## Notes & known limitations

- **State is local.** No remote backend is configured; `terraform.tfstate`
  lives on disk. Add a GCS backend for team use.
- **Public IPs on all nodes** and the `default` VPC network are used.
- `terraform.tfvars`, `*.tfstate`, `.terraform/`, and generated inventories are
  git-ignored — keep secrets out of version control.
- Lock down `ssh_source_ranges` to your own IP (`<your.ip>/32`) for least privilege.
