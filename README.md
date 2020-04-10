# Jitsi Meet on K3os

Scripts and tools to accomplish automated installations of [Jitsi Meet][1] with [k3os][2],
Rancher Labs' tiny Kubernetes distribution [k3s][3] on a bespoke operating system, 
all inside the KVM based open-source virtualization platform [Proxmox VE 6.1][4].

## Preparations

* remaster the K3OS ISO image: adapt `/boot/grub/grub.cfg` for fully automatic installation
```
k3os-remaster.sh /path/to/k3os-091-amd64.iso
```
* copy the remastered ISO `new-k3os-091-amd64.iso` to the image store of the Proxmox VE server
* create a customized `cloud-init` CDROM, using https://github.com/pagong/cloudinit-for-k3os
```
k3os-build.sh K3os-091-c
```
* copy the new `cloud-init` ISO `cidata-K3os-091-c.iso`to the image store of the Proxmox VE server, as well




[1]: https://github.com/jitsi/docker-jitsi-meet
[2]: https://github.com/rancher/k3os
[3]: https://github.com/rancher/k3s
[4]: https://www.proxmox.com/en/proxmox-ve

