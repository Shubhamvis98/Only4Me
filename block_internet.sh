#!/system/bin/sh

APPS='''
com.textra
com.adobe.scan.android
com.iudesk.android.photo.editor
homeworkout.homeworkouts.noequipment
com.termux
'''

cat << 'EOF'

  __ _    INTERNET            _ _ 
 / _(_)_ __ _____      ____ _| | |
| |_| | '__/ _ \ \ /\ / / _` | | |
|  _| | | |  __/\ V  V / (_| | | |
|_| |_|_|  \___| \_/\_/ \__,_|_|_|
                       BY FOSSFROG
				  
GITHUB: SHUBHAMVIS98
EOF

fuser()
{
	user=$(ls -l /data/data | grep "$1" | awk '{print $3}' | head -n1)
	i=$user
}

unblk()
{
	for app in $(echo $APPS)
	do
		echo -n "[*]Unblocking $app   --->    "
		fuser $app
		iptables -D OUTPUT -p all -m owner --gid-owner $i -j DROP 2>/dev/null \
			&& echo 'Done' || echo 'Not Exist'
	done
}

blk()
{
	for app in $(echo $APPS)
	do
		echo -n "[*]Blocking $app   --->   "
		fuser $app
		iptables -A OUTPUT -p all -m owner --gid-owner $i -j DROP 2>/dev/null \
			&& echo 'Done' || echo 'Not Exist'
	done
}

sleep 25 
blk
