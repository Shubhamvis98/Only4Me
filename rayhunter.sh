#!/bin/bash -e

adb push rootshell /tmp
sed -i 's|#device = "orbic"|device = "pinephone"|g' config.toml.in
adb push config.toml.in /tmp/config.toml
adb push rayhunter-daemon/rayhunter-daemon /tmp/rayhunter-daemon
adb push scripts/rayhunter_daemon /tmp/rayhunter_daemon
adb push scripts/misc-daemon /tmp/misc-daemon

adb shell mount -o remount,rw /
adb shell cp /tmp/rootshell /bin/rootshell
adb shell chown root /bin/rootshell
adb shell chmod 4755 /bin/rootshell
adb shell mkdir -p /data/rayhunter
adb shell mv /tmp/config.toml /data/rayhunter
adb shell mv /tmp/rayhunter-daemon /data/rayhunter
adb shell mv /tmp/rayhunter_daemon /etc/init.d/rayhunter_daemon
adb shell mv /tmp/misc-daemon /etc/init.d/misc-daemon
adb shell chmod 755 /data/rayhunter/rayhunter-daemon
adb shell chmod 755 /etc/init.d/rayhunter_daemon
adb shell ln -s /etc/init.d/rayhunter_daemon /etc/rc0.d/K02rayhunter_daemon
adb shell ln -s /etc/init.d/rayhunter_daemon /etc/rc1.d/K02rayhunter_daemon
adb shell ln -s /etc/init.d/rayhunter_daemon /etc/rc5.d/S98rayhunter_daemon
adb shell ln -s /etc/init.d/rayhunter_daemon /etc/rc6.d/K02rayhunter_daemon
adb shell shutdown -r -t 1 now
