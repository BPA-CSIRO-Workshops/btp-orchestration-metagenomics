#!/bin/bash

# Change this for your workshop repo:
workshop_repo="https://github.com/tsonika/NGS_intro_monash2016.git"

# Change this:
trainee_password="monashngs2016"

# Checkout workshop repo:
if [ ! -e "/tmp/btp-workshop" ]; then
  cd /tmp;
  git clone --recurse-submodules ${workshop_repo} btp-workshop;
fi
cd /tmp/btp-workshop;

# For each training module,
# retrieve corresponding datasets and install
# it on the training images/instances:
find . -type f -name 'data.yaml' | while read module; do
  module_name=$(echo ${module} | awk -F '/' '{ print $2 }');
  cat > /etc/puppet/${module_name}-datasets-hiera.yaml << EOF
---
:backends:
  - yaml
:yaml:
  :datadir: '/etc/puppet/'
:hierarchy:
  - ${module_name}-datasets
EOF
  echo "Processing (${module}/${module_name}) ..."
  cp ${module} /etc/puppet/${module_name}-datasets.yaml;
  puppet apply --verbose --parser future orchestration/puppet/btp-datasets.pp --hiera_config=/etc/puppet/${module_name}-datasets-hiera.yaml;
done;

# Create gsettings desktop script
# to customise trainee's desktop environment:
if [ ! -f "/etc/profile.d/gsettings.sh" ]; then
  cat > /etc/profile.d/gsettings.sh << EOF
/usr/bin/gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/backgrounds/ubuntu-gnome/ubuntu-gnome-wonders-of-nature.jpg"
/usr/bin/gsettings set org.gnome.desktop.lockdown disable-lock-screen true
/usr/bin/gsettings set org.gnome.desktop.session idle-delay 0
/usr/bin/gsettings set org.gnome.desktop.background show-desktop-icons true
/usr/bin/gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
/usr/bin/gsettings set org.gnome.shell.overrides button-layout ":minimize,maximize,close"
/usr/bin/gsettings set org.gnome.login-screen disable-restart-buttons true
/usr/bin/gsettings set org.gnome.shell enabled-extensions "['window-list@gnome-shell-extensions.gcampax.github.com']"
/usr/bin/gsettings set org.gnome.settings-daemon.plugins.remote-display active false
/usr/bin/gsettings set org.gnome.desktop.interface enable-animations false
EOF
  chmod a+x /etc/profile.d/gsettings.sh
fi

# Setup desktop shortcuts:
if [ ! -e "/home/trainee/Desktop/" ]; then
  mkdir /home/trainee/Desktop/
fi
cp /usr/share/applications/gnome-terminal.desktop /home/trainee/Desktop/
cp /usr/share/applications/firefox.desktop /home/trainee/Desktop/
cp /usr/share/applications/gedit.desktop /home/trainee/Desktop/
cp /usr/share/applications/libreoffice-calc.desktop /home/trainee/Desktop/
cp /usr/share/applications/libreoffice-writer.desktop /home/trainee/Desktop/
cp /usr/share/applications/IGV.desktop /home/trainee/Desktop/
chmod a+x -R /home/trainee/Desktop
chown trainee.trainee -R /home/trainee/Desktop

# Set trainee password:
echo "Setting password for trainee user ..."
echo -e "trainee:${trainee_password}" | sudo chpasswd
