<img src="https://camo.githubusercontent.com/5b298bf6b0596795602bd771c5bddbb963e83e0f/68747470733a2f2f692e696d6775722e636f6d2f7031527a586a512e706e67" align="left" width="144px" height="144px"/>

#### My homelab kubernetes infrastructure
> Terraform definition for my cluster via KVM and libvirt

[![Discord](https://img.shields.io/badge/discord-chat-7289DA.svg?maxAge=60&style=flat-square)](https://discord.gg/DNCynrJ)
[![k3s](https://img.shields.io/badge/k3s-v1.18.8-orange?style=flat-square)](https://k3s.io/)
[![GitHub stars](https://img.shields.io/github/stars/blackjid/k3s-gitops?color=green&style=flat-square)](https://github.com/blackjid/k3s-gitops/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/blackjid/k3s-gitops?style=flat-square)](https://github.com/blackjid/k3s-gitops/issues)
[![GitHub last commit](https://img.shields.io/github/last-commit/blackjid/k3s-gitops?color=purple&style=flat-square)](https://github.com/blackjid/k3s-gitops/commits/master)

<br/>

## Overview

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
