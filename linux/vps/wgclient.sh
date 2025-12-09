#!/bin/bash

next_ip() {
	used_ips=$(grep AllowedIPs "$WG_CONF" | awk '{print $3}' | cut -d'/' -f1 | cut -d'.' -f4)
	for i in $(seq 2 254); do
		if ! echo "$used_ips" | grep -q "^$i$"; then
			echo "${NETWORK_CIDR}.${i}/32"
			return
		fi
	done
	echo "No free IPs in subnet" >&2
	exit 1
}

create_peer() {
	[ -z "$1" ] && ALIAS='client' || ALIAS="$1"
	CLIENT_PRIV=$(wg genkey)
	CLIENT_PUB=$(echo "$CLIENT_PRIV" | wg pubkey)
	WG_CLIENT_IP=$(next_ip)

	wg set $WG_IF peer $CLIENT_PUB allowed-ips $WG_CLIENT_IP

	echo "[+] Creating client config..."
	[ ! -d "$WG_CLIENT_CONF" ] && mkdir $WG_CLIENT_CONF
	PEER_CONF_NAME=$WG_CLIENT_CONF/${ALIAS}_$(echo ${WG_CLIENT_IP%/32} | tr '.' '_').conf
	cat > $PEER_CONF_NAME <<EOF
[Interface]
PrivateKey = $CLIENT_PRIV
Address = ${WG_CLIENT_IP%/32}/24
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUB
Endpoint = $PUBLIC_IP:$WG_PORT
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF
	echo "[+] Peer config: $PEER_CONF_NAME"
}

remove_peer() {
	PEER="$1"
	if echo $PEER | base64 --decode >/dev/null 2>&1; then
		FOUND=$(grep -nr $PEER $WG_CLIENT_CONF | cut -d: -f1)
		echo "[+] Removing peer $PEER"
		wg set $WG_IF peer $PEER remove
		for i in /etc/wireguard/peers/*; do
			TMP_PUB=$(grep PrivateKey $i | awk '{print $3}' | wg pubkey)
			[ "$PEER" == "$TMP_PUB" ] && rm $i
		done
	else
		FOUND=$(grep -Fnr "10.0.0.${PEER}/24" $WG_CLIENT_CONF | cut -d: -f1)
		if [ "$FOUND" ]; then
			PEER=$(grep PrivateKey $FOUND | awk '{print $3}' | wg pubkey)
			remove_peer $PEER
		fi
	fi
}

restart_svc() {
	echo "[+] Re-writing ${WG_CONF}..."
	wg-quick save $WG_IF 2>/dev/null

	echo "[+] Restarting WireGuard..."
	systemctl restart wg-quick@$WG_IF
}

usage() {
	printf "Usage: $(basename $0) <opt> [<args>]\n\n"
	printf "Available options:\n"
	printf "\t%-9s %-2s %s\n" '-c' : 'Create new peer/client'
	printf "\t%-9s %-2s %s\n" '-C [arg]' : 'Create new peer/client with alias'
	printf "\t%-9s %-2s %s\n" '-d [arg]' : 'Delete existing peer/client'
}

WG_IF='wg0'
WG_CONF=/etc/wireguard/${WG_IF}.conf
WG_CLIENT_CONF=/etc/wireguard/peers
WG_PORT=$(wg show ${WG_IF} listen-port)
PUBLIC_IP=$(curl -s ifconfig.me)
SERVER_PUB=$(wg show ${WG_IF} public-key)
NETWORK_CIDR=$(grep Address /etc/wireguard/${WG_IF}.conf | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

while getopts ":cd:C:h" opt; do
	case $opt in
		c)
			create_peer
			restart_svc
		;;
		C)
			ALIAS=$OPTARG
			create_peer $ALIAS
			restart_svc
		;;
		d)
			TMP=$OPTARG
			remove_peer $TMP
			restart_svc
		;;
		h|?)
			usage
		;;
	esac
done
