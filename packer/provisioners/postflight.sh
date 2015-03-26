#!/bin/bash

# Postflight
apt-get update
apt-get install -y gnome-session-fallback
/usr/lib/lightdm/lightdm-set-defaults -s gnome-classic
/usr/lib/lightdm/lightdm-set-defaults -l false

# Disable LTS Upgrade Notification
sed -i 's/Prompt=lts/Prompt=never/g' /etc/update-manager/release-upgrades
