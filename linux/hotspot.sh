#!/bin/bash

if [ ${UID} -ne 0 ]; then
	echo '[!]Run as root'
	exit
fi

OPT=$1
DTIF=wlan0
APIF=wlan0_ap
APIF=ap0
CHAN=$(iw dev "$DTIF" info | grep channel | awk '{print $2}')

case $OPT in
	help)
		echo -e '\nUsage:'
		echo -e '\tenable\t#Start Hotspot'
		echo -e '\tdisable\t#Stop Hotspot\n'
		;;
	enable)
		if ip link show ${APIF} > /dev/null 2>&1; then
			echo '[+]Interface already exists, Restarting Services...'
			systemctl restart dnsmasq
			systemctl restart hostapd
			echo '[*]Done'
			exit
		fi

		echo '[+]Starting Hotspot...'
		sed -i "s/interface=.*/interface=${APIF}/;s/channel=.*/channel=${CHAN}/" \
			/etc/hostapd/hostapd.conf
		sed -i "s/interface=.*/interface=${APIF}/" /etc/dnsmasq.conf
		iw dev ${DTIF} interface add ${APIF} type __ap
		ip addr add 192.168.50.1/24 dev ${APIF}
		ip link set ${APIF} up
		sysctl -w net.ipv4.ip_forward=1 > /dev/null
		iptables -t nat -C POSTROUTING -o ${DTIF} -j MASQUERADE 2>/dev/null || \
			iptables -t nat -A POSTROUTING -o ${DTIF} -j MASQUERADE
		systemctl restart dnsmasq
		systemctl restart hostapd
		echo '[*]Done'
		;;
	disable)
		if ! ip link show ${APIF} > /dev/null 2>&1; then
			echo '[*]Already Stopped'
			exit
		fi
		echo '[+]Stopping Hotspot...'
		systemctl stop hostapd
		ip link set ${APIF} down
		iw dev ${APIF} del
		echo '[*]Done'
		;;
	*)
		if iw dev ${DTIF} link | grep -q "Connected"; then
			echo '[+]Wi-Fi Already Connected'
			$0 help
		else
			$0 enable
		fi
		;;
esac

