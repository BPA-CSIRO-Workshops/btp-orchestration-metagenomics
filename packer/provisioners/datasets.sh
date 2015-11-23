#!/bin/bash

if [ ! -e "/tmp/btp-workshop-ngs" ]; then
    cd /tmp;
    git clone --recurse-submodules https://github.com/BPA-CSIRO-Workshops/btp-workshop-ngs.git;
fi
cd /tmp/btp-workshop-ngs;

# Tools
find ../../ -type f -name 'data*.yaml' | while read module; do
    module_name=`echo $module | awk -F '/' '{ print $3 }'`;
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
    puppet apply --verbose --parser future btp-datasets.pp --hiera_config=/etc/puppet/$module_name-datasets-hiera.yaml;
done;
