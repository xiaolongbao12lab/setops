## 2026-09-10 - Ansible SSH Pipelining
**Learning:** Ansible modules execute slowly over high-latency networks because by default Ansible opens multiple SSH connections to copy, execute, and cleanup module payloads on remote servers.
**Action:** Enable `pipelining = True` in `ansible.cfg` under the `[ssh_connection]` section to pipe the module payload directly to the Python interpreter, drastically reducing the number of SSH operations and speeding up playbook execution. This works well with `become=True` as long as `requiretty` is disabled in `/etc/sudoers` on the remote hosts.
