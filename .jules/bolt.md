## 2025-01-01 - Enable Ansible Pipelining
**Learning:** By default, Ansible makes multiple SSH connections per task to execute modules. This overhead can be significant on large deployments. Enabling `pipelining = True` in `ansible.cfg` executes Python modules directly via pipe over a single SSH session.
**Action:** Always enable `pipelining = True` in `[ssh_connection]` block of `ansible.cfg` to dramatically speed up playbook execution, as long as `requiretty` is disabled in sudoers on target machines (which it usually is on modern distros).
