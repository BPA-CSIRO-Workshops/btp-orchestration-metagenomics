#!/bin/bash

apt-get update

###################
## Miscellaneous ##
###################
packages=(wget curl vim screen zip unzip)
apt-get install -y ${packages[@]} && apt-get clean
####################

###############
## Compilers ##
###############
packages=(gcc g++ gfortran cmake cmake-curses-gui)
apt-get install -y ${packages[@]} && apt-get clean
####################

#########
## SCM ##
#########
packages=(git mercurial subversion)
apt-get install -y ${packages[@]} && apt-get clean
####################

############
## Puppet ##
############
cd /tmp/
ubuntu_version=`lsb_release -s -c`
wget -4 --no-check-certificate https://apt.puppetlabs.com/puppetlabs-release-$ubuntu_version.deb
dpkg -i /tmp/puppetlabs-release-$ubuntu_version.deb
apt-get update
apt-get install -y puppet
rm /tmp/puppetlabs-release-$ubuntu_version.deb
####################
