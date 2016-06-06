#!/bin/bash

# Empty log files on the VM
find /var/log -type f -execdir truncate -s0 {} \;

# Disable LTS Upgrade Notification
sed -i 's/Prompt=lts/Prompt=never/g' /etc/update-manager/release-upgrades

# SSHD 
/bin/sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# Clean apt
apt-get -y clean all