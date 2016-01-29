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
In order to build the images using the recipes, Packer must be installed on the client machine. Packer packages are available for most platforms (Windows, Linux and OS X) and can be downloaded from the [Packer website][packer]. Once installed, the `packer` command line tool will be available on the system.

VirtualBox
----------
To create VirtualBox images, [VirtualBox][virtualbox] must be present on the client machine. Packer launches an Ubuntu virtual machine, installs required tools and downloads the datasets into the instance. Once this is completed, Packer packages the instance into a stand-alone image that can be loaded to other computers running VirtualBox.

VMWare
------
Similar to VirtualBox, VMWare  must be present on the client machine to create a virtual machine image for it. When building the BTP image from OS X, [VMWare Fusion][vmware-fusion] must be installed. When building from a Windows or Linux machine, [VMWare Workstation][vmware-workstation] must be installed.

NeCTAR Credentials
------------------
NeCTAR Credentials are used to interact with the cloud resources on the [NeCTAR Research Cloud][nectar-rc] using the NeCTAR APIs. The NeCTAR Credentials can be downloaded from the [NeCTAR Dashboard][nectar-dashboard]. More information can found in the [NeCTAR Authentication page][nectar-authentcation].

OpenStack Clients
-----------------
To launch the BTP using the NeCTAR API, the following OpenStack clients must be installed first of the machine:
* [`python-novaclient`][python-novaclient]
* [`python-heatclient`][python-heatclient]

AWS Credentials
---------------
An AWS account is required to be able to use the BTP on AWS. More information can be found on the [AWS website][aws]. AWS also provides a [free tier][aws-free] service to get users started quickly.

Creating BTP Images
===================
The following section outlines the steps for creating BTP images for the various platforms.

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

This process will take a while depending on the client machine and network configuration, as it installs the relevant tools and downloads the datasets into the virtual machine image. The resulting VirtualBox image will generated inside the `virtualbox` directory. This image can then be shared, other users can then load this image into their own machine running VirtualBox.

For building the VMWare image, the same process can be followed as VirtualBox, simply pass the VMWare build recipe to Packer. The VMWare image will be generated inside the `vmware` directory.

```
cd orchestration/packer/
packer build btp-vmware.json
```

The resulting `vmware` and `virtualbox` stand-alone images, can be easily shared to other users, and can then be easily loaded into VirtualBox and VMWare.

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

Source the OpenStack credentials file downloaded from the NeCTAR Dashboard for the desired user/tenant:
```
source openrc.sh
```

After sourcing the credentials file, the `OS_AUTH_URL`, `OS_TENANT_ID`, `OS_TENANT_NAME`, `OS_USERNAME` and `OS_PASSWORD` environment variables will be defined. These variables will be used by Packer to interact with the NeCTAR Research Cloud and provision an instance, which will then be configured to be a BTP image.

Build the NeCTAR-compatible image:
```
cd orchestration/packer/
packer build btp-nectar.json
```

Packer will launch an instance on the NeCTAR Research Cloud from a base Ubuntu LTS image. It will then continue to configure the instance with the required libraries, remote desktop server and analysis tools. Once this is completed, a `snapshot` of the instance will be created. This snapshot is then made available as the new BTP image across all availability zones in the NeCTAR Research Cloud. The new image can the be instantiated into instances from the [NeCTAR Dashboard][nectar-dashboard] or using the [NeCTAR API][nectar-api]. The workflows below describes how to use the included `heat` templates and sample commands for automated deployment of the BTP.

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

Packer reads the required credentials in the environment that's been configured after sourcing the credentials file. It then uses these credentials to interact with AWS to provision a build instance that'll be configured by the BTP with the relevant analysis tools and remote desktop software.

The BTP Amazon Machine Image (AMI) will generated by Packer after the build is complete. This AMI will then be visible and instantiable to the user.

Launching BTP Instances
=======================
This section outlines the steps to launch BTP instances on the various environments.

VirtualBox and VMWare
---------------------
The VirtualBox and VMWare images are available for download from the BTP workshop [release page][btp-ngs-release]. Once the image is downloaded, it can be loaded into VirtualBox and VMWare.

NeCTAR
------
Included in this repository is a `heat` template (`ngs-cfn.yaml`) that can be used on NeCTAR Research Cloud's [orchestration][nectar-rc-heat] service. The `heat` template (`ngs-cfn.yaml`) can be used directly on the [NeCTAR Dashboard][nectar-dashboard]. So first, one must login to the dashboard:

![NeCTAR Dashboard 01][nectar-db-01]

The orchestration service is then accessible from the left panel of the dashboard:

![NeCTAR Dashboard 02][nectar-db-02]

We can then initiate the process by clicking on the `Launch Stack` button on the top right section of the dashboard. This will trigger a pop-up menu to appear for selecting the `heat` template to run:

![NeCTAR Dashboard 03][nectar-db-03]

Make the `Template Source` as `File`, the then click on `Choose File`.
Now navigate to the workshop directory on your computer, in the top level path, there'll be a subdirectory called `orchestration`, open this directory, inside this, there'll be another subdirectory called `heat`, open this again and choose the `ngs-cfn.yaml` template inside it. Once the template file has been located and chosen, click on `Next` to got to the template input page:

![NeCTAR Dashboard 04][nectar-db-04]

The following parameters are mandatory for launching the `heat` template:
* `Stack Name`
* `Availability Zone`
* `Image Name`
* `Instance Count`
* `Instance Type`
* `Key Name`
* `Trainee Password`

`Stack Name` as the name suggests, just names the stack upon launch. This can be any name. The `Availability Zone` parameter allows users to choose where to launch the BTP instances on the NeCTAR Research Cloud. More information about availability zones can be found on this [support site][nectar-azs]. The `Image Name` contains a list of currently active and maintained BTP images. It's recommended to use the latest BTP image from the list. Multiple BTP instances can be launched simultaneously by entering the desired number in the `Instance Count` parameter. The size of the BTP instance/s in terms of vCPU count, memory and on-instance storage can be chosen by adjusting the `Instance Type` list. More information about instance types can be found on this [support site][nectar-resources]. The name of a key pair must be entered into the `Key Name` parameter. This key will be injected to the `root` user on the BTP instance and is used to access the BTP instances for administrative tasks. More information about key pairs can be found on this [support site][nectar-keypairs]. Lastly, the `Trainee Password` parameter is used for connecting to the launched BTP instance's using the trainee user. The trainee use's environment will be configured with the training modules associated to the workshop.

Once the parameters are completely filled, the launch process can be kicked-off by clicking the `Launch` button. The newly created stack with its status will then be shown on the dashboard:

![NeCTAR Dashboard 05][nectar-db-05]

While still on the dashboard, clicking on the name of the stack will display more informational tabs about the created stack. The `Resources` tab will show the resources created by the stack on the NeCTAR Research Cloud:

![NeCTAR Dashboard 06][nectar-db-06]

The `heat` stack creates two resources for a BTP instance, `AWS::EC2::Instance` and `AWS::EC2::SecurityGroup`. More information about these resources and other resources supported by the NeCTAR Research Cloud orchestration service can be found on this [support page][nectar-heat-resources]. The BTP instance is configured in the background. This is when the training modules and its datasets for the workshop are pulled from object storage and installed on the BTP instance. This process normally takes several minutes to complete. Once the stack creation is completed as reflected on its status on the dashboard, the BTP instance will then appear on the instances section of the dashboard:

![NeCTAR Dashboard 07][nectar-db-07]

It is important at this point to take note of the BTP instance's IP address as this will be used for remote desktop access later on using the [NoMachine][nomachine] remote desktop client.

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
[nectar-rc]: https://nectar.org.au/research-cloud/
[nectar-rc-heat]: https://support.rc.nectar.org.au/docs/heat
[nectar-authentication]: https://support.rc.nectar.org.au/docs/authentication
[nectar-dashboard]: https://support.rc.nectar.org.au/docs/dashboard
[nectar-api]: https://support.rc.nectar.org.au/docs/api-clients
[nectar-azs]: https://support.rc.nectar.org.au/docs/availability-zones
[nectar-keypairs]: https://support.rc.nectar.org.au/docs/keypairs
[nectar-resources]: https://support.rc.nectar.org.au/docs/resources-available
[nectar-heat-resources]: https://support.rc.nectar.org.au/docs/heat-supported-resources
[aws]: https://aws.amazon.com/
[aws-free]: https://aws.amazon.com/free/
[python-glanceclient]: https://github.com/openstack/python-glanceclient
[python-novaclient]: https://github.com/openstack/python-novaclient
[python-heatclient]: https://github.com/openstack/python-heatclient
[nomachine]: https://www.nomachine.com/

<!-- Figures -->
[nectar-db-01]: images/nectar-db-01.png
[nectar-db-02]: images/nectar-db-02.png
[nectar-db-03]: images/nectar-db-03.png
[nectar-db-04]: images/nectar-db-04.png
[nectar-db-05]: images/nectar-db-05.png
[nectar-db-06]: images/nectar-db-06.png
[nectar-db-07]: images/nectar-db-07.png
