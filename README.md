# Jitsi Meet on K3os

Scripts and tools to accomplish automated installations of [Jitsi Meet][1] with [k3os][2],
Rancher Labs' tiny Kubernetes distribution [k3s][3] on a bespoke operating system, 
all inside the KVM based open-source virtualization platform [Proxmox VE 6.1][4].


## 1st Part: install K3os on a Proxmox VM

### Preparations

- remaster the K3OS ISO image: adapt `/boot/grub/grub.cfg` for fully automatic installation
```
k3os-remaster.sh /path/to/k3os-091-amd64.iso
```
- copy the remastered ISO `new-k3os-091-amd64.iso` to the image store of the Proxmox VE server
- create a customized `cloud-init` CDROM, using https://github.com/pagong/cloudinit-for-k3os
- please adapt the `config.yaml` file (aka `user-data`) for your environment:
  - at least `hostname`, `password` for user `rancher` and the `ssh` keys should be changed
```
k3os-build.sh K3os-091-c
```
- copy the customized `cidata-K3os-091-c.iso` ISO to the image store of the Proxmox VE server


### Create a Proxmox VM for K3os

- create a new VM with at least 1 vCPU, 2 GB of memory and a 10 GB SCSI disk (`/dev/sda`)
- a virtual network card with access to a DHCP server and the internet is also recommended
- add 2 CDROM drives: 1st is for `new-k3os-0921-amd64.iso`, 2nd is for `cidata-K3os-091-c.iso`
- remember to enable the option `QEMU Guest Agent`
- power on the VM and watch the fully automatic installation


### Explore the K3os operating system

- after the reboot, you can login to the VM as user `rancher` with the preconfigured credentials
- have a look around:
```
lsblk ; blkid
ip a; ip r
df -h; date
```
- wait a few minutes, then explore the Kubernetes cluster
```
kubectl get nodes -o wide
kubectl get all -A
```

## 2nd Part: install containerized Jitsi Meet on K3os



[1]: https://github.com/jitsi/docker-jitsi-meet
[2]: https://github.com/rancher/k3os
[3]: https://github.com/rancher/k3s
[4]: https://www.proxmox.com/en/proxmox-ve

