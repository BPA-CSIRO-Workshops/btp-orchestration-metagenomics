This repository contains various orchestration template files used for
the automated bootstrapping of new Bioinformatics Training Platform
virtual machine images and instantiation of training instances.

Table of Contents
=================
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Prerequisites](#prerequisites)
  - [Packer](#packer)
  - [VirtualBox](#virtualbox)
  - [VMWare](#vmware)
  - [NeCTAR Credentials](#nectar-credentials)
  - [AWS Credentials](#aws-credentials)
- [Creating BTP Images](#creating-btp-images)
  - [VirtualBox and VMWare](#virtualbox-and-vmware)
  - [NeCTAR](#nectar)
  - [AWS](#aws)
- [Launching BTP Instances](#launching-btp-instances)
  - [VirtualBox and VMWare](#virtualbox-and-vmware-1)
  - [NeCTAR](#nectar-1)
  - [AWS](#aws-1)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Prerequisites
=============

Packer
------
In order to build the images using the recipes, 
Packer must be installed on the client machine.
Packer packages are available for most platforms and can be downloaded
from its [website](https://www.packer.io/downloads.html).

VirtualBox
----------
To create VirtualBox images, [VirtualBox](https://www.virtualbox.org/wiki/Downloads) must be present
on the client machine. Packer launches an Ubuntu virtual machine,
installs required tools and downloads the datasets into the instance.
Once this is completed, Packer packages the instance into a stand-alone
image that can be loaded to other computers running VirtualBox.

VMWare
------
Similar to VirtualBox, VMWare  must be present on the client
machine to create a virtual machine image for it. When building the BTP image
from OS X, [VMWare Fusion](http://www.vmware.com/products/fusion/overview.html) must be installed.
When building from a Windows or Linux machine, [VMWare Workstation](http://www.vmware.com/products/fusion/overview.html) must be installed.


NeCTAR Credentials
------------------
<TODO>

AWS Credentials
---------------
<TODO>

Creating BTP Images
===================
The following section outlines the steps for creating BTP images.

VirtualBox and VMWare
---------------------
[Install Packer](#prerequisites)

[Install VirtualBox or VMWare](#prerequisites)

Clone the BPA-CSIRO BTP NGS Workshop Repo
```
git clone https://github.com/BPA-CSIRO-Workshops/btp-workshop-ngs.git
```

Pull Relevant Training Modules
```
cd btp-workshop-ngs
git submodule update --init --recursive
```

Build VirtualBox and/or VMWare Images:
```
cd orchestration/packer/
packer build btp-virtualbox.json
```

This process will take a while depending on the client machine and network configuration,
as it installs the relevant tools and downloads the datasets into the virtual machine image.
The resulting VirtualBox image will generated inside the `virtualbox` directory.
This image can then be shared, other users can then load this image into their own machine
running VirtualBox.

For building the VMWare image, the same process can be followed as VirtualBox,
simply pass the VMWare build recipe to Packer. The VMWare image will be generated
inside the `vmware` directory.

```
cd orchestration/packer/
packer build btp-vmware.json
```

NeCTAR
------
<TODO>

AWS
---
<TODO>

Launching BTP Instances
=======================
This section outlines the steps to launch BTP instances on the various environments.

VirtualBox and VMWare
---------------------
<TODO>

NeCTAR
------
<TODO>

AWS
---
<TODO>

License
=======
The contents of this repository are released under the Creative Commons
Attribution 3.0 Unported License. For a summary of what this means,
please see: http://creativecommons.org/licenses/by/3.0/deed.en_GB
