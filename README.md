# homelab k3s cluster setup

## Nodes in KVM using libvirt

### Requirements

- Terraform 0.12
- Terraform Plugin **libvirt** [terraform provider](https://github.com/dmacvicar/terraform-provider-libvirt)
- libvirt 1.2.14 or newer development headers
- `mkisofs` to create the cloudinit iso
- A host ready for kvm and libvirt

On mac you can get get ready with this steps

```bash
brew install terraform libvirt cdrtools
./install_libvirt_terraform_provider.sh
```

### Prepare the host

- On Ubuntu distros SELinux is enforced by qemu even if it is disabled globally, this might cause unexpected `Could not open '/var/lib/libvirt/images/<FILE_NAME>': Permission denied` errors. Double check that `security_driver = "none"` is uncommented in `/etc/libvirt/qemu.conf` and issue `sudo systemctl restart libvirt-bin` to restart the daemon on your host.
- You need to be able to connect to the host via ssh using a public key

### Create the nodes

```bash
export TF_VAR_virt_host=<your_host_hostname_or_ip>
terraform init
terraform plan
terraform apply
```
