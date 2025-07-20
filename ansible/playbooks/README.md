Mostly notes on running these playbooks. Servers are not publically accessible, must be done locally or over VPN.

### For username/password
```
ansible-playbook update.yml -i hosts-file.yaml
```

### For SSH keys
```
ansible-playbook update.yml -i hosts-file.yaml --key-file "path/to/file"
```
