#!/bin/bash -e

WG_IF='wg0'
WG_PORT=51820
WG_NET='10.0.0.1/24'
ETH_IF=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
WG_CONF="/etc/wireguard/${WG_IF}.conf"

while getopts "f" opt; do
	case $opt in
		f)
			FORCE=1
			;;
	esac
done

if [[ -f "$WG_CONF" ]]; then
	if (( FORCE == 1 )); then
		echo "[+] Recreating wireguard server..."
	else
		echo "[!] Wireguard server already exists. Run with -f to recreate it."
		exit
	fi
fi

echo "[+] Generating server keys..."
SERVER_PRIV=$(wg genkey)
SERVER_PUB=$(echo "$SERVER_PRIV" | wg pubkey)

echo "[+] Creating ${WG_CONF}..."
cat > $WG_CONF <<EOF
[Interface]
Address = $WG_NET
ListenPort = $WG_PORT
PrivateKey = $SERVER_PRIV

PostUp   = iptables -A FORWARD -i $WG_IF -j ACCEPT; iptables -A FORWARD -o $WG_IF -j ACCEPT; iptables -t nat -A POSTROUTING -o $ETH_IF -j MASQUERADE
PostDown = iptables -D FORWARD -i $WG_IF -j ACCEPT; iptables -D FORWARD -o $WG_IF -j ACCEPT; iptables -t nat -D POSTROUTING -o $ETH_IF -j MASQUERADE

EOF

if [ ! $(sysctl -n net.ipv4.ip_forward) -eq 1 ]; then
	echo "[+] Enabling IP forwarding..."
	echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
	sysctl -p
fi

echo "[+] Starting WireGuard..."
ip link show $WG_IF >/dev/null 2>&1 && ip link del $WG_IF >/dev/null 2>&1
systemctl enable wg-quick@$WG_IF
systemctl restart wg-quick@$WG_IF
