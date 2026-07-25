set shell := ["bash", "-cu"]

export ANSIBLE_CONFIG := "ansible/ansible.cfg"

terraform_dir := "terraform"
ansible_dir := "ansible"

default:
    @just --list

# -----------------------------------------------------------------------------
# Terraform
# -----------------------------------------------------------------------------

fmt:
    terraform -chdir={{terraform_dir}} fmt -recursive

init:
    terraform -chdir={{terraform_dir}} init

validate:
    terraform -chdir={{terraform_dir}} validate

plan:
    terraform -chdir={{terraform_dir}} plan

apply:
    terraform -chdir={{terraform_dir}} apply -auto-approve

destroy:
    terraform -chdir={{terraform_dir}} destroy -auto-approve

output:
    terraform -chdir={{terraform_dir}} output

# -----------------------------------------------------------------------------
# Export Terraform outputs
# -----------------------------------------------------------------------------

domains:
    terraform -chdir={{terraform_dir}} output -json instance_domains \
      | jq '{instance_domains: .}' \
      > {{ansible_dir}}/domains.json

inventory:
    terraform -chdir={{terraform_dir}} output -raw inventory \
      > {{ansible_dir}}/inventory.ini

sync: inventory domains

# -----------------------------------------------------------------------------
# Ansible
# -----------------------------------------------------------------------------

galaxy:
    ansible-galaxy install -r {{ansible_dir}}/requirements.yml

ping:
    ansible all \
      -i {{ansible_dir}}/inventory.ini \
      -m ping

site:
    ansible-playbook \
      -i {{ansible_dir}}/inventory.ini \
      {{ansible_dir}}/site.yml \
      -e "@{{ansible_dir}}/domains.json"

baseline:
    ansible-playbook \
      -i {{ansible_dir}}/inventory.ini \
      {{ansible_dir}}/playbooks/baseline.yml \
      -e "@{{ansible_dir}}/domains.json"

artifact-storage:
    ansible-playbook \
      -i {{ansible_dir}}/inventory.ini \
      {{ansible_dir}}/playbooks/artifact-storage.yml \
      -e "@{{ansible_dir}}/domains.json"

ci-cd:
    ansible-playbook \
      -i {{ansible_dir}}/inventory.ini \
      {{ansible_dir}}/playbooks/ci-cd.yml \
      -e "@{{ansible_dir}}/domains.json"

code-quality:
    ansible-playbook \
      -i {{ansible_dir}}/inventory.ini \
      {{ansible_dir}}/playbooks/code-quality.yml \
      -e "@{{ansible_dir}}/domains.json"

# -----------------------------------------------------------------------------
# Full deployment
# -----------------------------------------------------------------------------

deploy:
    just fmt
    just init
    just validate
    just apply
    just domains
    just site



# -----------------------------------------------------------------------------
# Cleanup generated files
# -----------------------------------------------------------------------------
clean:
    rm -f {{ansible_dir}}/domains.json


# -----------------------------------------------------------------------------
# Destroy everything
# -----------------------------------------------------------------------------
teardown:
    just destroy



