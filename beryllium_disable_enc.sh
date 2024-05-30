#!/sbin/sh

mount /dev/block/by-name/vendor /vendor
find /vendor -name '*fstab*' -exec sed -i 's/,encryptable=footer//g;s/,fileencryption=ice,quota//g' {} \;
umount /vendor
