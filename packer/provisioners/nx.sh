#!/bin/bash

# NX
cd /tmp
wget -4 --no-check-certificate https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NX/nomachine_5.1.26_1_amd64.deb -O /tmp/nomachine_5.1.26_1_amd64.deb
dpkg -i /tmp/nomachine_5.1.26_1_amd64.deb
rm /tmp/nomachine_5.1.26_1_amd64.deb