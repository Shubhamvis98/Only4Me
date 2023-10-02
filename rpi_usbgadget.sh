#!/bin/bash

RPIBLOCK=$1

mount ${RPIBLOCK}p1 /mnt || exit 1
sed -i 's/rootwait/rootwait modules-load=dwc2,g_serial/g' /mnt/cmdline.txt
echo dtoverlay=dwc2 >> /mnt/config.txt
umount /mnt || exit 1

mount ${RPIBLOCK}p2 /mnt || exit 1
mkdir -p /mnt/etc/systemd/system/getty.target.wants
ln -sr /mnt/lib/systemd/system/getty@.service /mnt/etc/systemd/system/getty.target.wants/getty@ttyGS0.service
umount /mnt || exit 1
