sudo wpa_supplicant -Dwext -iwlan0 -c /home/lordievader/eduroam.conf&
sleep 5
sudo dhclient wlan0
