#!/bin/bash

# Desktop
apt-get update
apt-get install -y ubuntu-desktop
apt-get clean

# MATE
apt-add-repository -y ppa:ubuntu-mate-dev/ppa
apt-add-repository -y ppa:ubuntu-mate-dev/trusty-mate
apt-get update
apt-get upgrade -y
apt-get install -y ubuntu-mate-core ubuntu-mate-desktop
