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
  cat > /home/trainee/.config/autostart/session-desktop << EOF
[Desktop Entry]
Name=NGS-Nature
GenericName=NGS-Nature
Comment=NGS-Nature
Exec=/home/trainee/.config/gsettings
Type=Application
X-GNOME-Autostart-enabled=true
EOF
fi

# Create gsettings desktop script
# to customise trainee's desktop environment:
if [ ! -f "/home/trainee/.config/gsettings" ]; then
  cat > /home/trainee/.config/gsettings << EOF
#!/bin/bash

gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/backgrounds/ubuntu-gnome/ubuntu-gnome-wonders-of-nature.jpg"
gsettings set org.gnome.desktop.lockdown disable-lock-screen true
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.background show-desktop-icons true
EOF
fi

# Verify trainee ownership of config dir:
chown trainee.trainee -R /home/trainee/.config

# Set trainee password:
echo "Setting password for trainee user ..."
echo -e "trainee:${trainee_password}" | sudo chpasswd
