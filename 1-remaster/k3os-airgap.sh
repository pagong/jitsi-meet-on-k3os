#!/bin/bash
# MIT License. See LICENSE file.

ISO=$1
TAR=$2

################

# check if given ARG1 is a K3OS iso image
OK=0
if [ -f $ISO ] ; then
	OK=1
	KIND=$( blkid $ISO )
	if [ ! $( echo $KIND | grep -q 'TYPE="iso9660"' ) ] ; then
		OK=2
		if [ ! $( echo $KIND | grep -q 'LABEL="K3OS"' ) ] ; then
			OK=3
		fi
	fi
fi

if [ $OK != 3 ] ; then
	echo "ARG1 must be an ISO image of K3OS."
	exit 1
fi

################

OK=0
if [ -d $TAR ] ; then
	OK=1
	KIND=$( file $TAR/*.tar )
	if [ ! $( echo $KIND | grep -q 'POSIX tar' ) ] ; then
		OK=2
	fi
fi

if [ $OK != 2 ] ; then
	echo "ARG2 must be a directory of TAR files containing K3S airgap images."
	exit 1
fi

################

DATADIR="/mnt/new"

# mount current K3OS image
mkdir -p /mnt/orig /mnt/new
mount -o ro,loop $ISO /mnt/orig

# copy data from orig to new
cp -rfp /mnt/orig/k3os $DATADIR

# create new grub.cfg
#cp /mnt/orig/boot/grub/grub.cfg /mnt/new/boot/grub/
mkdir -p $DATADIR/boot/grub
cp -p grub/grub-fai4.cfg $DATADIR/boot/grub/grub.cfg

# copy airgap images into /var/lib/rancher/k3s/agent/images
IMGDIR="/var/lib/rancher/k3s/agent/images"
mkdir -p $DATADIR/airgap
cp -p $TAR/*.tar $DATADIR/airgap

################

if [ $# -eq 2 ]; then
	FNAME=$( basename $ISO)
	FILENAME="airgap-$FNAME"
	echo "Building image to $FILENAME ..."
else 
	echo "Usage: ./k3os-airgap.sh [k3os-version].iso [dir-of-airgap-images]"
	exit 1
fi

# Debian, Ubuntu
#CMD=grub-mkrescue
# SUSE
CMD=grub2-mkrescue

# grub-mkrescue -o k3os-new.iso iso/ -- -volid K3OS

# make remastered ISO
$CMD	 -output $FILENAME	/mnt/new/	\
			-- -volid "K3OS" 	\
	2> build.log

################

FILESIZE=$(stat -c %s $FILENAME 2>/dev/null)
COLUMNS=$(tput cols)
if [[ $FILESIZE > 0 ]]; then
	printf '%s (%d bytes) ... done!\n' $FILENAME $FILESIZE
else
	printf 'Something went wrong while trying to make %s\n' $FILENAME
fi

################

# unmount and cleanup
umount /mnt/orig
rm -rf /mnt/new /mnt/orig

