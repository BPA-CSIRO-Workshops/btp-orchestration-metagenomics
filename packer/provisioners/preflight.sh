#!/bin/bash

# Preflight
rm -r /var/lib/apt/lists/*
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y

# Reboot
reboot
sleep 60
