#!/bin/bash

# Kernel update
sudo rpi-update -y

# install Pi-Hole on Raspberry Pi
curl -sSL https://install.pi-hole.net | bash

# install unbound
sudo apt install unbound -y

# download unbound root hints
wget https://www.internic.net/domain/named.root -qO- | sudo tee /var/lib/unbound/root.hints

# user name
user=$USER

# creat root hints
rootHintsFile="home/$user/update_root_hints.sh"
mkdir -p "home/$user"
curl -o "$rootHintsFile" https://raw.githubusercontent.com/melrydin/piHoleUnboundSkript/master/update_root_hints.sh

# create unbound config file
unboundConfigFile="/etc/unbound/unbound.conf.d/pi-hole.conf"
mkdir -p "/etc/unbound/unbound.conf.d"
curl -o "$unboundConfigFile" https://raw.githubusercontent.com/melrydin/piHoleUnboundSkript/master/pi-hole.conf

# add Cronjob
(crontab -l 2>/dev/null || true; echo "* * * */3 * root /home/$user/update_unbound_dns.sh >/dev/null 2>&1") | crontab -

# update dnsmasq.d
dnsmasqFile="/etc/dnsmasq.d/99-edns.conf"
newValue="edns-packet-max=1232"
sudo sed -i "s/^edns-packet-max=.*/$newValue/" "$dnsmasqFile"

# restart unbound
sudo service unbound restart

# disable unboud-resolvconf.service
sudo systemctl disable --now unbound-resolvconf.service

# Pi-hole DNS settings to unbound
dig pi-hole.net @127.0.0.1 -p 5335

# check DNSSEC
dig txt qnamemintest.internet.nl +short @127.0.0.1 -p 5335
dig dnssec.works @127.0.0.1 -p 5335