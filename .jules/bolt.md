## $(date +%Y-%m-%d) - [Enable SSH Pipelining for Ansible]
**Learning:** SSH operations natively in Ansible are an enormous bottleneck when provisioning multiple machines since Ansible copies scripts and establishes multiple SSH connections for every task. By default, it's disabled for legacy safety (`requiretty`).
**Action:** Always enable `pipelining = True` in `[ssh_connection]` inside `ansible.cfg` to optimize Ansible performance whenever modifying Ansible infrastructures, as it drastically reduces the number of SSH operations and deployment times.
