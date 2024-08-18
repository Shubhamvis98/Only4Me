#!/bin/bash

[ ! -d ramdisk/scripts/local-premount ] && echo '[!] Ramdisk extract not found' && exit

cat <<'eof'> ramdisk/scripts/local-premount/losetup_root_img
#!/bin/sh

set -e

case "${1}" in
        prereqs)
                exit 0
                ;;
esac

mkdir /userdata
mount `blkid -t PARTLABEL=userdata -o device` /userdata || exit 0

ROOTIMG='/userdata/media/0/TWRP/phosh.img'

if [ -e "$ROOTIMG" ]
then
    losetup -f $ROOTIMG
else
    umount /userdata
    rmdir /userdata
fi

eof

sed -i '1i/scripts/local-premount/losetup_root_img "$@"\n[ -e /conf/param.conf ] && . /conf/param.conf' \
	ramdisk/scripts/local-premount/ORDER
