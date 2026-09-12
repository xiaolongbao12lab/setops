## $(date +%Y-%m-%d) - [Enable SSH Pipelining for Ansible]
**Learning:** SSH operations natively in Ansible are an enormous bottleneck when provisioning multiple machines since Ansible copies scripts and establishes multiple SSH connections for every task. By default, it's disabled for legacy safety (`requiretty`).
**Action:** Always enable `pipelining = True` in `[ssh_connection]` inside `ansible.cfg` to optimize Ansible performance whenever modifying Ansible infrastructures, as it drastically reduces the number of SSH operations and deployment times.
## 2026-09-05 - Optimize apt cache updates
**Learning:** The playbook updates the apt cache multiple times in different roles (e.g. `docker`, `jenkins`, `nginx`) using `update_cache: true`. By combining this with `cache_valid_time: 3600`, we avoid redundant and expensive `apt-get update` calls on subsequent playbook runs within the time window. This significantly speeds up the playbook execution.
**Action:** Use `cache_valid_time: 3600` (or a similar suitable value) alongside `update_cache: true` when installing packages with the `apt` module, especially if multiple roles are called sequentially.
