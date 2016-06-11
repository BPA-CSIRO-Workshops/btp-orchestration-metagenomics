#!/bin/bash

# Change this for your workshop repo:
workshop_repo="https://github.com/BPA-CSIRO-Workshops/btp-workshop-ngs.git"

# Change this:
trainee_password="trainee"

# Checkout workshop repo:
if [ ! -e "/tmp/btp-workshop-ngs" ]; then
  cd /tmp;
  git clone --recurse-submodules ${workshop_repo};
fi
cd /tmp/btp-workshop-ngs;

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

# Create autostart dir for trainee user:
if [ ! -e "/home/trainee/.config/autostart" ]; then
  mkdir -p /home/trainee/.config/autostart
fi

cat > /home/trainee/.config/autostart/btp.desktop << EOF
[Desktop Entry]
Name=BTP-Script
GenericName=BTP-Script
Comment=NGS-Nature
Exec=btp-custom
Type=Application
Icon=system-run
Terminal=false
X-GNOME-Autostart-enabled=true
EOF

if [ ! -e "/home/trainee/bin" ]; then
  mkdir -p /home/trainee/bin
  chown trainee.trainee /home/trainee/bin
fi

# Create gsettings desktop script
# to customise trainee's desktop environment:
if [ ! -f "/home/trainee/bin/btp-custom" ]; then
  cat > /home/trainee/bin/btp-custom << EOF
#!/bin/bash
gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/backgrounds/ubuntu-gnome/ubuntu-gnome-wonders-of-nature.jpg"
gsettings set org.gnome.desktop.lockdown disable-lock-screen true
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.background show-desktop-icons true
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
gsettings set org.gnome.shell.overrides button-layout ":minimize,maximize,close"
gsettings set org.gnome.login-screen disable-restart-buttons true
gsettings set org.gnome.shell enabled-extensions "['window-list@gnome-shell-extensions.gcampax.github.com']"
EOF
  chmod a+x /home/trainee/bin/btp-custom
fi

# Setup desktop shortcuts:
if [ ! -e "/home/trainee/Desktop/" ]; then
  mkdir /home/trainee/Desktop/
fi
cp /usr/share/applications/gnome-terminal.desktop /home/trainee/Desktop/
cp /usr/share/applications/firefox.desktop /home/trainee/Desktop/
cp /usr/share/applications/gedit.desktop /home/trainee/Desktop/
cp /usr/share/applications/libreoffice-calc.desktop /home/trainee/Desktop/
cp /usr/share/applications/libreoffice-write.desktop /home/trainee/Desktop/
cp /usr/share/applications/IGV.desktop /home/trainee/Desktop/
chmod a+x -R /home/trainee/Desktop
chown trainee.trainee -R /home/trainee/Desktop

# Verify trainee ownership of config dir:
chown trainee.trainee -R /home/trainee/.config

# Set trainee password:
echo "Setting password for trainee user ..."
echo -e "trainee:${trainee_password}" | sudo chpasswd
