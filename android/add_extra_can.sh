#!/bin/bash -x

git clone https://github.com/V0lk3n/usb-can-2-module drivers/net/can/usb-can-2-module
awk -v p='source "' -v t='source "drivers/net/can/usb-can-2-module/Kconfig"' '$0 ~ p {last=NR} {lines[NR]=$0} END {for(i=1;i<=NR;i++){print lines[i]; if(i==last) print t}}' drivers/net/can/Kconfig > tmp && mv tmp drivers/net/can/Kconfig
awk -v p='obj-y' -v t='obj-y				+= usb-can-2-module/' '$0 ~ p {last=NR} {lines[NR]=$0} END {for(i=1;i<=NR;i++){print lines[i]; if(i==last) print t}}' drivers/net/can/Makefile > tmp && mv tmp drivers/net/can/Makefile

git clone https://github.com/V0lk3n/can-isotp drivers/net/can/can-isotp
mv drivers/net/can/can-isotp/include/uapi/linux/can/isotp.h include/uapi/linux/can
rm -rf drivers/net/can/can-isotp/include
awk -v p='source "' -v t='source "drivers/net/can/can-isotp/Kconfig"' '$0 ~ p {last=NR} {lines[NR]=$0} END {for(i=1;i<=NR;i++){print lines[i]; if(i==last) print t}}' drivers/net/can/Kconfig > tmp && mv tmp drivers/net/can/Kconfig
awk -v p='obj-y' -v t='obj-y				+= can-isotp/' '$0 ~ p {last=NR} {lines[NR]=$0} END {for(i=1;i<=NR;i++){print lines[i]; if(i==last) print t}}' drivers/net/can/Makefile > tmp && mv tmp drivers/net/can/Makefile

git clone https://github.com/V0lk3n/elmcan
sed -i 's|static unsigned int \*can327_mailbox_read|static unsigned int can327_mailbox_read|' elmcan/can327.c
cp elmcan/can327.c drivers/net/can/
rm -rf elmcan
awk -v p='obj-\$' -v t='obj-$(CONFIG_CAN_CAN327)	+= can327.o' '$0 ~ p {last=NR} {lines[NR]=$0} END {for(i=1;i<=NR;i++){print lines[i]; if(i==last) print t}}' drivers/net/can/Makefile > tmp && mv tmp drivers/net/can/Makefile
awk -v p="endmenu" -v t=$'config CAN_CAN327\n\ttristate "Serial / USB serial ELM327 based OBD-II Interfaces (can327)"\n\tdepends on TTY\n\tselect CAN_RX_OFFLOAD\n\t---help---\n\tCAN driver for several \'low cost\' OBD-II interfaces based on the\n\t  ELM327 OBD-II interpreter chip.\n\t  This is a best effort driver - the ELM327 interface was never\n\t  designed to be used as a standalone CAN interface. However, it can\n\t  still be used for simple request-response protocols (such as OBD II),\n\t  and to monitor broadcast messages on a bus (such as in a vehicle).\n\t  Please refer to the documentation for information on how to use it:\n\t  Documentation/networking/device_drivers/can/can327.rst\n\t  If this driver is built as a module, it will be called can327.\n' \
'{a[NR]=$0; if($0~p) l=NR} END{for(i=1;i<=NR;i++) {if(i==l) print t; print a[i]}}' drivers/net/can/Kconfig > tmp && mv tmp drivers/net/can/Kconfig

