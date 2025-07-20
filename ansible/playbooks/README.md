Mostly notes on running these playbooks. Servers are not publically accessible, must be done locally or over VPN.

### For username/password
```
ansible-playbook update.yml -i inventory.yaml -l homelab
```

### For SSH keys
This particular environment utilizes password more than key files (it's a homelab, come on). However, in the off-chance you utilize keys or have a one-off at a remote location (Oracle, Azure, etc), the command below allows for key files.

```
ansible-playbook update.yml -i inventory.yaml --key-file=/path/to/key-file
```

If you don't want to type in in the command every time, you can place the key file in your `inventory.yaml` file like this:

```
ip-or-hostname:
  ansible_user: <username-associated-with-key-file>
  ansible_ssh_private_key_file: /path/to/key-file
  ansible_ask_pass: false
```

Then run
```
ansible-playbook update.yml -i inventory.yaml -l <list-name>
```

You'll still be prompted for an SSH password and BECOME. Just hit enter for both of these.
