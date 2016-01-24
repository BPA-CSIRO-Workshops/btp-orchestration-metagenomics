#!/bin/bash

# Desktop
apt-get update
apt-get install -y ubuntu-desktop
/bin/sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# NX
cd /tmp
wget -4 --no-check-certificate https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NX/nomachine_5.0.63_1_amd64.deb
dpkg -i nomachine_5.0.63_1_amd64.deb nomachine_5.0.63_1_amd64.deb
rm nomachine_5.0.63_1_amd64.deb

# Disable LTS Upgrade Notification
sed -i 's/Prompt=lts/Prompt=never/g' /etc/update-manager/release-upgrades
