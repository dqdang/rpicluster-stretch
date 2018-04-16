#!/bin/bash

echo "
Enabling Wifi-Wifi networking scheme . . .
"

count=0
total=9
start=`date +%s`

while [ $count -lt $total ]; do
    cur=`date +%s`

	if [$count == 0] then

		# ---------------------------------------------
		# echo "
		# Generating new wpa_supplicant . . .
		# "
		sudo cp /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant-wlan1.conf
		sudo bash /rpicluster/network-manager/set-wifi.sh wpa_supplicant-wlan1.conf
		# ---------------------------------------------
	elif [$count == 1] then
		# echo "
		# Installing host services . . .
		# "
		sudo apt-get install -y dnsmasq
		sudo apt-get install -y hostapd
		sudo apt-get install -y rng-tools
		# ---------------------------------------------
	elif [$count == 2] then

		# echo "
		# Updating dhcpcd.conf . . .
		# "
		sudo mv /etc/dhcpcd.conf /etc/dhcpcd.conf.orig

		sudo echo "interface wlan0
		metric 150
		static ip_address=192.168.1.254/24
		#static routers=192.168.1.1
		static domain_name_servers=8.8.8.8 #192.168.1.1

		interface wlan1
		metric 100" >> /etc/dhcpcd.conf
		# ---------------------------------------------
	elif [$count == 3] then

		# echo "
		# Generating new hostapd.conf . . .
		# "
		sudo echo "interface=wlan0
		driver=nl80211
		ssid=rpicluster-AP
		channel=1
		wmm_enabled=0
		wpa=1
		wpa_passphrase=rpicluster
		wpa_key_mgmt=WPA-PSK
		wpa_pairwise=TKIP
		rsn_pairwise=CCMP
		auth_algs=1
		macaddr_acl=0
		logger_stdout=-1
		logger_stdout_level=2
		" > /etc/hostapd/hostapd.conf
		# ---------------------------------------------
	elif [$count == 4] then

		# echo "
		# Linking new hostapd.conf . . .
		# "

		sudo sed -i '10s/.*/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/' /etc/default/hostapd

		sudo sed -i '19s/.*/DAEMON_CONF=\/etc\/hostapd\/hostapd.conf/' /etc/init.d/hostapd
		# ---------------------------------------------
	elif [$count == 5] then

		# echo "
		# Generating new dnsmasq.conf . . .
		# "

		sudo echo "no-resolv
		interface=wlan0
		listen-address=192.168.1.254
		server=8.8.8.8 # Use Google DNS
		domain-needed # Don't forward short names
		bogus-priv # Drop the non-routed address spaces.
		dhcp-range=192.168.1.100,192.168.1.150,12h # IP range and lease time
		#log each DNS query as it passes through
		log-queries
		dhcp-authoritative
		" > /etc/dnsmasq.conf

		sudo cp /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
		# ---------------------------------------------
	elif [$count == 6] then

		# echo "
		# Generating new iptable Rules . . .
		# "

		sudo iptables -F
		sudo iptables -t nat -F
		sudo iptables -t nat -A POSTROUTING -o wlan1 -j MASQUERADE 
		sudo iptables -A FORWARD -i wlan1 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
		sudo iptables -A FORWARD -i wlan0 -o wlan1 -j ACCEPT
		# ---------------------------------------------
	elif [$count == 7] then

		# echo "
		# Allowing ip_forward . . .
		# "

		sudo sed -i '28 s/#//' /etc/sysctl.conf

		sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
		# ---------------------------------------------
	elif [$count == 8] then

		# echo "
		# Updating startup activities . . .
		# "
		sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

		sudo sed -i '20i\iptables-restore < \/etc\/iptables.ipv4.nat\' /etc/rc.local
		# ---------------------------------------------
	fi
    count=$(( $count + 1 ))
    pd=$(( $count * 73 / $total ))
    runtime=$(( $cur-$start ))
    estremain=$(( ($runtime * $total / $count)-$runtime ))
    printf "\r%d.%d%% complete ($count of $total) - est %d:%0.2d remaining\e[K" $(( $count*100/$total )) $(( ($count*1000/$total)%10)) $(( $estremain/60 )) $(( $estremain%60 ))
done
