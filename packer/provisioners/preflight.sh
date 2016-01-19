#!/bin/bash

# Preflight
rm -r /var/lib/apt/lists/*
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get autoremove -y;
apt-get clean
echo "precedence ::ffff:0:0/96 100" >> /etc/gai.conf

# Reboot
reboot
sleep 60
