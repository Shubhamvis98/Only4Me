clear
toilet --gay "p o s t g r e s q l________" -f wideterm
toilet --gay "~~~~~~~~~~~~~~~~S E R V E R" -f wideterm
echo
echo
echo "Start & Stop postgresql Database Server"
echo
if [[ -z "$1" ]]
then
	cat $PREFIX/local/bin/pstart_ins
	echo
	echo -n "Enter: "
	read IN
	if [ $IN == s ]
	then
		echo "Starting Database Server..."
		sleep 0.5
		pg_ctl start
		echo

	elif [ $IN == x ]
	then
		echo "Stopping Database Server..."
		sleep 0.5
		pg_ctl stop
		echo

	elif [ $IN == e ]
	then
		echo "Exitting Script..."
		sleep 0.5
		echo
		clear
		exit

	else
		sleep 0.5
		echo "INVALID INPUT"
		sleep 0.5
		read -p "Try Again..."
		$0
	fi

else
	pg_ctl $1
fi
