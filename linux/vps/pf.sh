#!/bin/bash

#######################################
# Validate IPv4 Address
#######################################
validate_ip() {
	local ip=$1
	local stat=1

	if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
		IFS='.' read -r o1 o2 o3 o4 <<< "$ip"
		if (( o1 <= 255 && o2 <= 255 && o3 <= 255 && o4 <= 255 )); then
			stat=0
		fi
	fi
	return $stat
}

#######################################
# Validate Port (1–65535)
#######################################
validate_port() {
	local port=$1
	if [[ $port =~ ^[0-9]+$ ]] && (( port >= 1 && port <= 65535 )); then
		return 0
	else
		return 1
	fi
}

#######################################
# Check if port is already in use
#######################################
check_port_in_use() {
	local port=$1

	# Prefer ss
	if command -v ss >/dev/null 2>&1; then
		if ss -ltnu | grep -qE ":$port\b"; then
			return 1
		fi
	# Fallback to netstat
	elif command -v netstat >/dev/null 2>&1; then
		if netstat -ltnu 2>/dev/null | grep -qE ":$port\b"; then
			return 1
		fi
	else
		echo "Warning: Neither ss nor netstat found. Cannot validate open ports."
		return 0
	fi

	return 0
}

usage() {
	printf "Usage: $(basename $0) <opt> [<args>]\n\n"
	printf "Available options:\n"
	printf "\t%-9s %-2s %s\n" '-a' : 'Add rule'
	printf "\t%-9s %-2s %s\n" '-d' : 'Remove rule'
	printf "\t%-9s %-2s %s\n" '-s' : 'Show rules'
	printf "\t%-9s %-2s %s\n" '-i [arg]' : 'Peer IP'
	printf "\t%-9s %-2s %s\n" '-h [arg]' : 'Host port'
	printf "\t%-9s %-2s %s\n" '-c [arg]' : 'Peer port'
	exit
}

#######################################
# Default values
#######################################
DEFAULT_CLIENT_IP='10.0.0.2'
HOST_PORT=80
CLIENT_PORT=80

#######################################
# Parse args with getopts
#######################################
while getopts "adsi:h:c:" opt; do
	case $opt in
	a)
		FLAG='-A'
		;;
	d)
		FLAG='-D'
		;;
	i)
		DEFAULT_CLIENT_IP="$OPTARG"
		;;
	h)
		HOST_PORT="$OPTARG"
		;;
	c)
		CLIENT_PORT="$OPTARG"
		;;
	s)
		iptables -v -t nat -L PREROUTING --line-numbers
		exit
		;;
	*)
		usage
		exit 1
		;;
	esac
done

#######################################
# Validate inputs
#######################################
if [ -z "$FLAG" ]; then
	usage
	exit 1
fi

if ! validate_ip "$DEFAULT_CLIENT_IP"; then
	echo "Error: Invalid IP address '$DEFAULT_CLIENT_IP'"
	exit 1
fi

if ! validate_port "$HOST_PORT"; then
	echo "Error: Invalid HOST_PORT '$HOST_PORT' (must be 1-65535)"
	exit 1
fi

if ! check_port_in_use "$HOST_PORT"; then
	echo "Error: HOST_PORT '$HOST_PORT' is already in use."
	exit 1
fi

#######################################
# Print validated arguments
#######################################
echo "Validated inputs:"
echo "DEFAULT_CLIENT_IP = $DEFAULT_CLIENT_IP"
echo "HOST_PORT         = $HOST_PORT"
echo "CLIENT_PORT       = $CLIENT_PORT"
echo

#######################################
# Apply iptables rule
#######################################
RULE="-p tcp --dport ${HOST_PORT} -j DNAT --to-destination ${DEFAULT_CLIENT_IP}:${CLIENT_PORT}"

case "$FLAG" in
	-I|-A)
		# Add the rule only if it does not already exist
		if iptables -t nat -C PREROUTING $RULE 2>/dev/null; then
			echo "Rule already exists. Skipping insertion."
		else
			iptables -t nat $FLAG PREROUTING $RULE
			echo "Rule inserted."
		fi
		;;
	-D)
		# Delete the rule only if it exists
		if iptables -t nat -C PREROUTING $RULE 2>/dev/null; then
			iptables -t nat -D PREROUTING $RULE
			echo "Rule deleted."
		else
			echo "Rule does not exist. Skipping deletion."
		fi
		;;
	*)
		echo "ERROR: Unsupported FLAG '$FLAG'. Must be -I, -A, or -D."
		exit 1
		;;
esac
