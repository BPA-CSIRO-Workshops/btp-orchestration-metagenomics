#!/bin/bash

# Checkout workshop repo
if [ ! -e "/tmp/btp-workshop-ngs" ]; then
  cd /tmp;
  git clone --recurse-submodules https://github.com/BPA-CSIRO-Workshops/btp-workshop-ngs.git;
fi
cd /tmp/btp-workshop-ngs;

# For each training module,
# retrieve corresponding datasets and install
# it on the training images/instances.
find . -type f -name 'data.yaml' | while read module; do
  module_name=`echo $module | awk -F '/' '{ print $2 }'`;
  cat > /etc/puppet/$module_name-datasets-hiera.yaml << EOF
---
:backends:
- yaml
:yaml:
:datadir: '/etc/puppet/'
:hierarchy:
- $module_name-datasets
EOF

  cp $module /etc/puppet/$module_name-datasets.yaml;
  puppet apply --verbose --parser future orchestration/puppet/btp-datasets.pp --hiera_config=/etc/puppet/$module_name-datasets-hiera.yaml;
done;

echo "Setting password for trainee user ..."
echo -e "trainee:trainee_password" | sudo chpasswd
