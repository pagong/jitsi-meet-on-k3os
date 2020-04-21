# Jitsi Meet on K3os

Scripts and tools to accomplish automated installations of [Jitsi Meet][1] with [k3os][2]
(Rancher Labs' tiny Kubernetes distribution [k3s][3] on a bespoke operating system), 
all inside the KVM based open-source virtualization platform [Proxmox VE 6.1][4].


## 1st Part: install K3os on a Proxmox VM

We want to create a virtual machine (VM) using the KVM hypervisor of Proxmox, without using any manual steps.

In oder to accomplish this, we need a customized version of the K3os ISO image, 
that does not ask any questions during installation.
For each new version of K3os, this remastered ISO image needs to be created only once.
With [`cloud-init`][5] technology, it is possible to inject unique configuration data (aka `config.yaml`) 
into the fully automatic installation process of a K3os VM.
So for each K3os instance, that we want to create, a separate `cloud-init` CDROM (ISO image) needs to be built.

Refer to Rancher Labs' [Github repo][2] for documentation on installing and running K3os.


### Preparations

- remaster the K3OS ISO image: adapt `/boot/grub/grub.cfg` for fully automatic installation
```
( cd 1-remaster ; sudo k3os-remaster.sh /path/to/k3os-0100-amd64.iso )
```
- copy the remastered ISO `new-k3os-0100-amd64.iso` to the image store of the Proxmox VE server
- create a customized `cloud-init` CDROM, using https://github.com/pagong/cloudinit-for-k3os
- please adapt the `user-data` file (aka `config.yaml`) for your environment:
  - at least `hostname`, `password` for user `rancher` and the `ssh` keys should be changed
```
( cd 2-cloudinit ; k3os-build.sh jitsi3 )
```
- copy the customized `cidata-jitsi3.iso` ISO to the image store of the Proxmox VE server


### Create a Proxmox VM for K3os

- create a new VM with at least 2 vCPU, 3 GB of memory and a 20 GB SCSI disk (`/dev/sda`)
- a virtual network card with access to a DHCP server and the internet is also recommended
- add 2 CDROM drives: 1st is for `new-k3os-0100-amd64.iso`, 2nd is for `cidata-jitsi3.iso`
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
- use `sudo -i` to become user `root` and explore the unique features of K3os :smile:


## 2nd Part: install containerized Jitsi Meet on K3os

German computer magazine c't featured the [`team-container`][6] project in it's issue [9/2020][7]. 
This project implements containerized team apps, like Nextcloud, Rocket.Chat and Jitsi Meet, on a Kubernetes platform.
c't are using Ubuntu and [k3s][3] as container infrastructure. I would like to use [k3os][2] instead.


### First impressions

Parts of the `install.sh` script of the c't project have been integrated into the `user-data` file for `jitsi3`.

The download and installation of `helm3` does not work on `k3os`. 
Some small modifications to the downloaded helm3 installer script are needed:
```
diff helm3-installer.sh-orig helm3-installer.sh-new
--- helm3-installer.sh-orig
+++ helm3-installer.sh-new
@@ -131,7 +131,7 @@
 # installs it.
 installFile() {
   HELM_TMP="$HELM_TMP_ROOT/$BINARY_NAME"
-  local sum=$(openssl sha1 -sha256 ${HELM_TMP_FILE} | awk '{print $2}')
+  local sum=$(sha256sum ${HELM_TMP_FILE} | awk '{print $1}')
   local expected_sum=$(cat ${HELM_SUM_FILE})
   if [ "$sum" != "$expected_sum" ]; then
     echo "SHA sum of ${HELM_TMP_FILE} does not match. Aborting."
```


[1]: https://github.com/jitsi/docker-jitsi-meet
[2]: https://github.com/rancher/k3os
[3]: https://github.com/rancher/k3s
[4]: https://www.proxmox.com/en/proxmox-ve
[5]: https://cloudinit.readthedocs.io/en/latest/
[6]: https://github.com/ct-Open-Source/team-container
[7]: https://www.heise.de/select/ct/2020/9/2007712573850503640
