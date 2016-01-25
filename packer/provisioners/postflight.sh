#!/bin/bash

# Desktop
apt-get update
apt-get install -y ubuntu-desktop
/bin/sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# NX
cd /tmp
wget -4 --no-check-certificate https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NX/nomachine_5.0.63_1_amd64.deb
dpkg -i nomachine_5.0.63_1_amd64.deb
rm nomachine_5.0.63_1_amd64.deb

# Clean up udev rules to prevent incrementing network card IDs
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
    rm /etc/udev/rules.d/70-persistent-net.rules
    touch /etc/udev/rules.d/70-persistent-net.rules
fi

[ -d /dev/.udev ] && rm -rf /dev/.udev

# Empty log files on the VM
find /var/log -type f -execdir truncate -s0 {} \;

# Remove SSH host keys
rm -f /etc/ssh/*key*

# Disable LTS Upgrade Notification
sed -i 's/Prompt=lts/Prompt=never/g' /etc/update-manager/release-upgrades

# Clean apt
apt-get -y clean all
