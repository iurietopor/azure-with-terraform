# linux-vm-learn-terraform

This is a simple ['Quickstart: Use Terraform to create a Linux VM'](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-terraform) from Microsoft.

This 'Quickstart' include:

- Create a virtual network
- Create a subnet
- Create a public IP address
- Create a network security graoup and SSH inbound rule
- Create a virtual network interface card
- Connect the network security group to the network interface
- Create a storage account for boot diagnostics
- Create SSH key
- Create a virtual machine
- Use ssh to connect to virtual machine

## `ssh_connect.sh`

This is a script which automaticaly connect to your VM after `terraform apply`.
This script validate automaticaly the ssh_key, and ip_address from `terraform output ...` commands.

For more details see:
```bash
./ssh_connect.sh -h
```

---
