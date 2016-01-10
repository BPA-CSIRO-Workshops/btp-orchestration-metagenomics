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
Packer packages are available for most platforms (Windows, Linux and OS X) and can be downloaded
from the [Packer website][packer]. Once installed,
the `packer` command line tool will be available on the system.

VirtualBox
----------
To create VirtualBox images, [VirtualBox][virtualbox] must be present
on the client machine. Packer launches an Ubuntu virtual machine,
installs required tools and downloads the datasets into the instance.
Once this is completed, Packer packages the instance into a stand-alone
image that can be loaded to other computers running VirtualBox.

VMWare
------
Similar to VirtualBox, VMWare  must be present on the client
machine to create a virtual machine image for it. When building the BTP image
from OS X, [VMWare Fusion][vmware-fusion] must be installed.
When building from a Windows or Linux machine, 
[VMWare Workstation][vmware-workstation] must be installed.

NeCTAR Credentials
------------------
NeCTAR Credentials must be downloaded from the NeCTAR Dashboard
to interact with the NeCTAR APIs and cloud resources,
more information can found in the [NeCTAR Authentication page][nectar-authentcation].

OpenStack Clients
-----------------

AWS Credentials
---------------
An AWS account is required to be able to use the BTP
on AWS. More information can be found on the [AWS website][aws].
AWS provides a [free tier][aws-free] service to get users started quickly.

Creating BTP Images
===================
The following section outlines the steps for creating BTP images.

VirtualBox and VMWare
---------------------
[Install Packer](#prerequisites)

[Install VirtualBox or VMWare](#prerequisites)

Clone the BPA-CSIRO BTP NGS Workshop repository
```
git clone https://github.com/BPA-CSIRO-Workshops/btp-workshop-ngs.git
```

Pull the training submodules
```
cd btp-workshop-ngs
git submodule update --init --recursive
```

Build the VirtualBox and/or VMWare image:
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

The resulting `vmware` and `virtualbox` stand-alone images,
can be easily shared to other users, and can then be easily
loaded into VirtualBox and VMWare.

NeCTAR
------

Clone the BPA-CSIRO BTP NGS Workshop repository
```
git clone https://github.com/BPA-CSIRO-Workshops/btp-workshop-ngs.git
```

Pull the training modules
```
cd btp-workshop-ngs
git submodule update --init --recursive
```

Build the NeCTAR-compatible image:
```
cd orchestration/packer/
packer build btp-qemu.json
```

Packer will generate a `.qcow2` image file inside the qemu directory.
This image can then be uploaded to the NeCTAR Image catalog using 
the [`python-glanceclient`][python-glanceclient].

Source the OpenStack credentials file downloaded from NeCTAR:
```
source openrc.sh
```

Upload the `.qcow2` image into the NeCTAR Research Cloud
```
glance image-create --name="BTP-Image-V1.0" --disk-format=qcow2 --container-format=bare < BTP-2015-12-29.qcow2
```

The new image is the uploaded and now available on the NeCTAR Research Cloud.
It can be instantiated into instances on the NeCTAR Research Cloud,
from the [NeCTAR Dashboard][nectar-dashboard] or using the [NeCTAR API][nectar-api].

AWS
---
Clone the BPA-CSIRO BTP NGS Workshop Repo
```
git clone https://github.com/BPA-CSIRO-Workshops/btp-workshop-ngs.git
```

Pull the training sub modules
```
cd btp-workshop-ngs
git submodule update --init --recursive
```

Source the AWS credential file:
```
source aws-ap-southeast-2.sh
```

The command show above is an examle of sourcing 
the AWS credentials for the `ap-southeast-2` region.

Build the AWS image:
```
cd orchestration/packer/
packer build btp-aws.json
```

Packer reads the required credentials in the environment that's
been configured after sourcing the credentials file.
It then uses these credentials to interact with AWS
to provision a build instance that'll be configured by the BTP
with the relevant analysis tools and remote desktop software.

The BTP Amazon Machine Image (AMI) will generated by Packer
after the build is complete. This AMI will then be visible
and instantiable to the user.

Launching BTP Instances
=======================
This section outlines the steps to launch BTP instances on the various environments.

VirtualBox and VMWare
---------------------
The VirtualBox and VMWare images are available for download
from the BTP workshop [release page][btp-ngs-release].
Once the image is downloaded, it can be loaded into VirtualBox and VMWare.

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

[packer]: https://www.packer.io/downloads.html
[virtualbox]: http://www.vmware.com/products/fusion/overview.html
[vmware-fusion]: http://www.vmware.com/products/fusion/overview.html
[vmware-workstation]: http://www.vmware.com/products/fusion/overview.html
[btp-ngs-release]: https://github.com/BPA-CSIRO-Workshops/btp-workshop-ngs/releases
[nectar-authentication]: https://support.rc.nectar.org.au/docs/authentication
[nectar-dashboard]: https://support.rc.nectar.org.au/docs/dashboard
[nectar-api]: https://support.rc.nectar.org.au/docs/api-clients
[aws]: https://aws.amazon.com/
[aws-free]: https://aws.amazon.com/free/
[python-glanceclient]: https://github.com/openstack/python-glanceclient
