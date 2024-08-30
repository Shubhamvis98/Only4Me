#!/bin/bash

RAMDISK=ramdisk/scripts/local-premount
SCRIPT=${RAMDISK}/losetup_root_img


[ ! -d "${RAMDISK}" ] && echo '[!] Ramdisk extract not found' && exit

cat <<'eof'> ${SCRIPT}
#!/bin/sh

# This script runs during the init-premount phase and sets up a loop
# device for the root filesystem image from any partition specified
# by the rootimg= value in the cmdline, along with the full path to
# the rootfs image file.
# Example:
#	In the context of Android, if you've stored the rootfs image in
# the eMMC path (e.g., /sdcard/myrootfs.img), you can provide the
# following command line value to boot the OS from the rootfs image:
# rootimg=PARTLABEL=userdata/media/0/myrootfs.img

set -e

case "${1}" in
	prereqs)
		exit 0
		;;
esac

for x in $(cat /proc/cmdline); do
	case $x in
		rootimg=*)
			ROOTIMG=${x#rootimg=}
			IMGPART=${ROOTIMG%%/*}
			IMGPATH=${ROOTIMG#*=}
			MNTDIR=${IMGPATH%%/*}
			;;
	esac
done

# Exit if empty
[ -z "${IMGPART}" ] && exit

# Find block device
if [ -b /dev/${IMGPART} ]
then
    DEVICE=/dev/${IMGPART}
elif blkid -t ${IMGPART} -o device > /dev/null
then
    DEVICE=`blkid -t ${IMGPART} -o device`
else
	exit
fi

# Mount and losetup the image file
mkdir -p ${MNTDIR}
mount ${DEVICE} ${MNTDIR}

if [ -f "${IMGPATH}" ]
then
	losetup -f ${IMGPATH}
else
	umount ${MNTDIR}
	rmdir ${MNTDIR}
fi

eof

chmod 755 ${SCRIPT}
if ! grep -q losetup_root_img ${RAMDISK}/ORDER
then
	sed -i '1i/scripts/local-premount/losetup_root_img "$@"\n[ -e /conf/param.conf ] && . /conf/param.conf' \
		${RAMDISK}/ORDER
fi

