# setops

Infrastructure-as-code for provisioning **Google Cloud Ubuntu VMs** with **Terraform** and configuring them with **Ansible**.

The project supports two stages:

* **DevOps VMs** — Docker, Portainer, Jenkins, GitHub CLI, Nexus, SonarQube.
* **Kubernetes cluster** — Automated cluster creation with **Kubespray**.

---

## Architecture

```text
Terraform
   |
   |  create VMs + firewall
   v
Generated Ansible inventory
   |
   v
Ansible
   |
   +-- DevOps stack
   |
   +-- Kubernetes cluster (Kubespray)
```

---

## Prerequisites

* Terraform >= 1.5
* Ansible >= 2.15
* Google Cloud SDK
* SSH key pair

Authenticate with GCP:

```bash
gcloud auth application-default login
```

---

## Quick Start

### 1. Provision Infrastructure

```bash
cd terraform

cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

Terraform will:

* Create the VM instances
* Configure firewall rules
* Generate the Ansible inventory automatically

---

### 2. Configure DevOps Hosts

```bash
cd ../ansible

ansible-galaxy collection install -r requirements.yml
ansible-playbook site.yml
```

Installed components:

* Docker
* Portainer
* Jenkins
* GitHub CLI

---

## Kubernetes Cluster

The Kubernetes automation is located in **k8s/** and uses **Kubespray**.

### Create the cluster

```bash
cd k8s

python3 -m venv .venv
source .venv/bin/activate

pip install -r requirements.txt

ansible-playbook playbooks/prepare.yml
ansible-playbook playbooks/install.yml
```

This stage currently automates:

* Kubespray installation
* Inventory generation from Terraform
* Kubernetes control plane and worker nodes
* kubeconfig setup for the control machine
* Cluster verification with `kubectl`

### Verify

```bash
kubectl get nodes
```

Example:

```text
NAME                          STATUS   ROLES
setops-kubernetes-master-0    Ready    control-plane
setops-kubernetes-master-1    Ready    control-plane
setops-kubernetes-master-2    Ready    control-plane
setops-kubernetes-worker-0    Ready    <none>
setops-kubernetes-worker-1    Ready    <none>
setops-kubernetes-worker-2    Ready    <none>
```

> The project currently stops at **Kubernetes cluster creation**.

---

## Project Structure

```text
terraform/
  main.tf
  firewall.tf
  inventory.tf
  templates/

ansible/
  site.yml
  playbooks/
  roles/

k8s/
  playbooks/
  roles/
  kubespray/
  inventory/
```

---

## Notes

* Terraform uses **local state** by default.
* All nodes currently receive **public IPs**.
* Generated inventories and Terraform state are ignored by Git.
* Restrict `ssh_source_ranges` to your own IP for better security.

---

## Current Features

### DevOps Stack

* Docker
* Portainer
* Jenkins
* GitHub CLI
* Nexus OSS (role available)
* SonarQube (role available)

### Kubernetes

* Terraform-generated Kubespray inventory
* Automated cluster provisioning
* Multi-master control plane
* Worker node provisioning
* kubeconfig configuration on the control machine
* Cluster validation with `kubectl`

---

## Status

| Feature                     | Status         |
| --------------------------- | -------------- |
| Terraform provisioning      | ✅              |
| Ansible baseline            | ✅              |
| Jenkins                     | ✅              |
| Nexus OSS role              | ✅              |
| SonarQube role              | ✅              |
| Kubernetes cluster creation | ✅              |
| Traefik automation          | ⚠️ In progress |
| Headlamp automation         | ⏳ Planned      |
| ArgoCD automation           | ⏳ Planned      |

The repository is currently stable up to **Kubernetes cluster creation and kubectl access from the control machine**.
