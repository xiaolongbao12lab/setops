## 2023-10-24 - Enable Ansible Pipelining
**Learning:** SSH connection overhead can severely degrade Ansible execution time, especially for complex deployments across multiple VMs like in Kubespray or DevOps stack setups.
**Action:** Always enable `pipelining = True` in the `[ssh_connection]` block of `ansible.cfg` when the environment supports it (requires `requiretty` to be disabled in sudoers, which is the default in modern Ubuntu).
