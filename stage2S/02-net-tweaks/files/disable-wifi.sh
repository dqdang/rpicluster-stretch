#!/bin/bash -e


echo "
Disabling Wifi-Wifi networking scheme . . .
"
echo "
removing wlan1 wpa_supplicant . . .
"
sudo rm /etc/wpa_supplicant/wpa_supplicant-wlan1.conf


echo "
Restoring dhcpcd.conf . . .
"
sudo rm /etc/dhcpcd.conf
sudo mv /etc/dhcpcd.conf.orig /etc/dhcpcd.conf


echo "
Removing hostapd.conf . . .
"
sudo rm /etc/hostapd/hostapd.conf


echo "
Unlinking hostapd.conf . . .
"

sudo sed -i '10s/.*/#DAEMON_CONF=""/' /etc/default/hostapd

sudo sed -i '19s/.*/#DAEMON_CONF=/' /etc/init.d/hostapd


echo "
Restoring dnsmasq.conf . . .
"

sudo rm /etc/dnsmasq.conf
sudo touch /etc/dnsmasq.conf

echo "
Restoring rc.local / .profile . . .
"

sed -i '20d' /etc/rc.local
# sudo sed -i '25d' /home/pi/.profile

