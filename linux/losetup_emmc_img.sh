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
			IMGPART=`echo ${ROOTIMG} | cut -d'/' -f2`
			;;
	esac
done

if [ -n "${IMGPART}" ]
then
	mkdir /${IMGPART}
	mount `blkid -t PARTLABEL=${IMGPART} -o device` /${IMGPART} || exit 0

	if [ -f "${ROOTIMG}" ]
	then
		losetup -f ${ROOTIMG}
	else
		umount /${IMGPART}
		rmdir /${IMGPART}
	fi
fi

eof

chmod 755 ${SCRIPT}
if ! grep -q losetup_root_img ${RAMDISK}/ORDER
then
	sed -i '1i/scripts/local-premount/losetup_root_img "$@"\n[ -e /conf/param.conf ] && . /conf/param.conf' \
		${RAMDISK}/ORDER
fi

