#!/bin/bash

RAMDISK=ramdisk/scripts/local-premount
SCRIPT=${RAMDISK}/losetup_root_img


[ ! -d "${RAMDISK}" ] && echo '[!] Ramdisk extract not found' && exit

cat <<'eof'> ${SCRIPT}
#!/bin/sh

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
elif blkid -t ${IMGPART} -o device
then
    DEVICE=`blkid -t ${IMGPART} -o device`
else
	exit
fi

# Mount and losetup the image file
mkdir -p ${MNTDIR}
mount ${DEVICE} ${MNTDIR} || exit

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

