## README.md
# Persistent Reverse SSH Tunnel Add-on


This add-on uses `autossh` to keep a reverse SSH tunnel from Home Assistant to a remote server. It supports pasting your private key into the addon configuration or referencing a path under `/data`.


Basic usage:
1. Install the add-on (add repository to Supervisor -> Add-on Store).
2. Configure the options (remote_host, remote_user, remote_ssh_port, remote_listen_port, local_target_host, local_target_port, private_key).
3. Start the add-on.


Security notes:
- Keep your private key safe. Consider using a key with a passphrase and an SSH agent on the remote side, or use a dedicated key with limited rights on the remote server.
- When `GatewayPorts` is set to `yes` or `clientspecified`, forwarded ports may listen on 0.0.0.0 on the remote server. Use `clientspecified` if you want the remote side to decide.


Troubleshooting:
- Check addon logs in Supervisor -> Add-on -> Log.
- Ensure the remote server allows GatewayPorts and that `sshd` does not block forced tunnels.
- If connection fails, verify the private key and user permissions on remote server's authorized_keys.


---


# End of add-on files