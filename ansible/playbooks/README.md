Mostly notes on running these playbooks. Servers are not publically accessible, must be done locally or over VPN.

### For username/password
```
ansible-playbook update.yml -i hosts-file.yaml --ask-pass --ask-become-pass --extra-vars "ansible_user=$(read -p 'SSH Username: ' u && echo $u)"
```
`--ask-pass` and `--ask-become-pass` are the same. Just hit enter when prompted for the BECOME password as it'll default to the provided SSH password.

### For SSH keys
```
ansible-playbook update.yml -i hosts-file.yaml --extra-vars "ansible_user=$(read -p 'SSH Username: ' u && echo $u)" --key-file "path/to/file"
```
