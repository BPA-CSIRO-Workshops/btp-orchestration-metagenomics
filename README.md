This repository contains various orchestration template files used for
the automated bootstrapping of new Bioinformatics Training Platform
virtual machine images and instantiation of training instances.

Table of Contents
=================
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
BTP Orchstration

- [Prerequisites](#prerequisites)
  - [Packer](#packer)
  - [VirtualBox](#virtualbox)
  - [VMWare](#vmware)
  - [NeCTAR Credentials](#nectar-credentials)
  - [OpenStack Clients](#openstack-clients)
  - [AWS Credentials](#aws-credentials)
  - [NoMachine](#nomachine)
- [Creating BTP Images](#creating-btp-images)
  - [VirtualBox and VMWare](#virtualbox-and-vmware)
  - [NeCTAR](#nectar)
  - [AWS](#aws)
- [Launching BTP Instances](#launching-btp-instances)
  - [AWS](#aws-1)
- [Accessing BTP Instances](#accessing-btp-instances)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Prerequisites
=============

Packer
------
In order to build the images using the recipes, 
Packer must be installed on the client machine. 
Packer packages are available for most platforms (Windows, 
Linux and OS X) and can be downloaded from the
[Packer website](https://www.packer.io/downloads.html). 
Once installed, the `packer` command line tool will be available on the system.

VirtualBox
----------
To create VirtualBox images, [VirtualBox][virtualbox] must be present on the client machine. 
Packer launches an Ubuntu virtual machine, installs required tools and downloads the datasets 
into the instance. Once this is completed, Packer packages the instance into a stand-alone image
that can be loaded to other computers running VirtualBox.

VMWare
------
Similar to VirtualBox, VMWare  must be present on the client machine to create a virtual machine 
image for it. When building the BTP image from OS X, [VMWare Fusion][vmware-fusion] must be installed. 
When building from a Windows or Linux machine, [VMWare Workstation][vmware-workstation] must be installed.

NeCTAR Credentials
------------------
NeCTAR Credentials are used to interact with the cloud resources on the [NeCTAR Research Cloud][nectar-rc] 
using the NeCTAR APIs. The NeCTAR Credentials can be downloaded from the [NeCTAR Dashboard][nectar-dashboard]. 
More information can found in the [NeCTAR Authentication page][nectar-authentcation].

OpenStack Clients
-----------------
To launch the BTP using the NeCTAR API, the following OpenStack clients must be installed first of the machine:
* [`python-novaclient`][python-novaclient]
* [`python-heatclient`][python-heatclient]

AWS Credentials
---------------
An AWS account is required to be able to use the BTP on AWS. 
More information can be found on the [AWS website][aws]. 
AWS also provides a [free tier][aws-free] service to get users started quickly.

NoMachine
---------
NoMachine remote desktop server is installed on the BTP images for the NeCTAR Research Cloud and AWS. 
To be able to connect to the BTP instances on the cloud, NoMachine must be installed on the client machine. 
It is available for the major operating systems (e.g Windows, Linux and Mac OS X). 
More information about NoMachine and links to its package installers for the various platforms
can be found on its [website][NoMachine].

Creating BTP Images
===================
The following section outlines the steps for creating BTP images for the NeCTAR Research Cloud and AWS, 
as well as stand-alone virtual machine images that can be used directly on VirtualBox and VMWare.

VirtualBox and VMWare
---------------------
[Install Packer](#prerequisites)

[Install VirtualBox or VMWare](#prerequisites)

<!-- WORKSHOP DYNAMIC -->
Clone the BPA-CSIRO BTP NGS workshop repository and its submodules:
```
git clone --recursive https://github.com/BPA-CSIRO-Workshops/btp-workshop-ngs.git
```

Build the VirtualBox and/or VMWare image:
```
cd orchestration/packer/
packer build btp-virtualbox.json
```

This process will take a while depending on the client machine and network configuration, 
as it installs the relevant tools and downloads the datasets into the virtual machine image. 
The resulting VirtualBox image will generated inside the `virtualbox` directory. 
This image can then be shared, other users can then load this image into their 
own machine running VirtualBox.

For building the VMWare image, the same process can be followed as VirtualBox, 
simply pass the VMWare build recipe to Packer. The VMWare image will be generated 
inside the `vmware` directory.

```
cd orchestration/packer/
packer build btp-vmware.json
```

The resulting `vmware` and `virtualbox` stand-alone images, can be easily shared to other users, 
and can then be easily loaded into VirtualBox and VMWare.

NeCTAR
------

There are prebuilt BTP images available on the NeCTAR Research Cloud. 
These images are created and maintained by the workshop developers and organisers. 
It can be launched on any of the availability zones of the NeCTAR Research Cloud. 
More information about the NeCTAR Research Cloud is available on its [website][nectar-rc]. 
Information about NeCTAR availability zones is available on this [page][nectar-azs].

First thing to do is to clone the BTP workshop repository and its submodules:
<!-- WORKSHOP DYNAMIC -->
```
git clone --recursive https://github.com/BPA-CSIRO-Workshops/btp-workshop-ngs.git
```

The next step is to source the NeCTAR OpenStack credentials file. 
This is used for interacting with the NeCTAR API. Source the OpenStack credentials 
file downloaded from the NeCTAR Dashboard for the desired user/tenant:
```
source openrc.sh
```

After sourcing the credentials file, the `OS_AUTH_URL`, `OS_TENANT_ID`, `OS_TENANT_NAME`, 
`OS_USERNAME` and `OS_PASSWORD` environment variables will be defined. 
These variables will be used by Packer to interact with the NeCTAR Research Cloud and 
provision an instance, which will then be configured to be a BTP image.

Build the NeCTAR-compatible image:
```
cd orchestration/packer/
packer build btp-nectar.json
```

Packer will launch an instance on the NeCTAR Research Cloud from a base Ubuntu LTS image. 
It will then continue to configure the instance with the required libraries, 
remote desktop server and analysis tools. Once this is completed, 
a `snapshot` of the instance will be created. This snapshot is then made available as 
the new BTP image across all availability zones in the NeCTAR Research Cloud. 
The new image can the be launched into instances from the [NeCTAR Dashboard][nectar-dashboard]
or using the [NeCTAR API][nectar-api]. The workflows below describes how to use 
the included `heat` templates and sample commands for automated deployment of the BTP.

AWS
---

<!-- WORKSHOP DYNAMIC -->
Clone the BPA-CSIRO BTP NGS workshop repository and its submodules:
```
git clone --recursive https://github.com/BPA-CSIRO-Workshops/btp-workshop-ngs.git
```

<!-- WORKSHOP DYNAMIC -->
Pull the training sub modules for the workshop from GitHub:
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

Packer reads the required credentials in the environment that's been configured 
after sourcing the credentials file. It then uses these credentials to interact 
with AWS to provision a build instance that'll be configured by the BTP with the
relevant analysis tools and remote desktop software.

The BTP Amazon Machine Image (AMI) will generated by Packer after the build is complete.
This AMI will then be visible and instantiable to the user.

Launching BTP Instances
=======================
This section outlines the steps to launch BTP instances on the various environments.

<!-- WORKSHOP DYNAMIC -->
VirtualBox and VMWare
---------------------
The VirtualBox and VMWare images are available for download from the BTP workshop 
[release page][btp-ngs-release]. Once the image is downloaded,
it can be loaded into VirtualBox and VMWare.

<!-- WORKSHOP DYNAMIC -->
NeCTAR
------

Included in this repository is a `heat` template (`ngs-cfn.yaml`) that can be used 
on NeCTAR Research Cloud's [orchestration][nectar-rc-heat] service. The `heat` template 
(`ngs-cfn.yaml`) can be used directly on the [NeCTAR Dashboard][nectar-dashboard]. 
To get the `heat` template, the BTP workshop repository and its submodules 
must be cloned from GitHub first:

<!-- WORKSHOP DYNAMIC -->
Clone the BPA-CSIRO BTP NGS workshop repository and its submodules:
```
git clone --recursive https://github.com/BPA-CSIRO-Workshops/btp-workshop-ngs.git
```

Then the user can login to the dashboard:

![NeCTAR Dashboard 01][nectar-db-01]

The orchestration service is then accessible from the left panel of the dashboard:

![NeCTAR Dashboard 02][nectar-db-02]

We can then initiate the process by clicking on the `Launch Stack` 
button on the top right section of the dashboard. This will trigger a pop-up
menu to appear for selecting the `heat` template to run:

<!-- WORKSHOP DYNAMIC -->
![NeCTAR Dashboard 03][nectar-db-03]

Make the `Template Source` as `File`, the then click on `Choose File`.
Now navigate to the workshop directory on your computer, in the top level path, 
there'll be a subdirectory called `orchestration`, open this directory, inside this,
there'll be another subdirectory called `heat`, open this again and choose the 
`ngs-cfn.yaml` template inside it. Once the template file has been located and chosen,
click on `Next` to got to the template input page:

![NeCTAR Dashboard 04][nectar-db-04]

The following parameters are mandatory for launching the `heat` template: 
`Stack Name`, `Availability Zone`, `Image Name`, `Instance Count`, 
`Instance Type`, `Key Name` and `Trainee Password`.

`Stack Name` as the name suggests, just names the stack upon launch. This can be any name. 
The `Availability Zone` parameter allows users to choose where to launch the BTP instances
on the NeCTAR Research Cloud. More information about availability zones can be found on this
[support site][nectar-azs]. The `Image Name` contains a list of currently active and
maintained BTP images. It's recommended to use the latest BTP image from the list.
Multiple BTP instances can be launched simultaneously by entering the desired number
in the `Instance Count` parameter. The size of the BTP instance/s in terms of vCPU count,
memory and on-instance storage can be chosen by adjusting the `Instance Type` list.
More information about instance types can be found on this [support site][nectar-resources].
The name of a key pair must be entered into the `Key Name` parameter. This key will be 
injected to the `root` user on the BTP instance and is used to access the BTP instances 
for administrative tasks. More information about key pairs can be found on this 
[support site][nectar-keypairs]. Lastly, the `Trainee Password` parameter is used for
connecting to the launched BTP instance's using the trainee user. The trainee use's 
environment will be configured with the training modules associated to the workshop.

Once the parameters are completely filled, the launch process can be kicked-off by
clicking the `Launch` button. The newly created stack with its status will then be 
shown on the dashboard:

![NeCTAR Dashboard 05][nectar-db-05]

While still on the dashboard, clicking on the name of the stack will display more 
informational tabs about the created stack. The `Resources` tab will show the resources
created by the stack on the NeCTAR Research Cloud:

![NeCTAR Dashboard 06][nectar-db-06]

The `heat` stack creates two resources for a BTP instance, `AWS::EC2::Instance` 
and `AWS::EC2::SecurityGroup`. More information about these resources and other resources
supported by the NeCTAR Research Cloud orchestration service can be found on this 
[support page][nectar-heat-resources]. The BTP instance is configured in the background. 
This is when the training modules and its datasets for the workshop are pulled from 
object storage and installed on the BTP instance. This process normally takes several 
minutes to complete. Once the stack creation is completed as reflected on its status on 
the dashboard, the BTP instance will then appear on the instances section of the dashboard:

![NeCTAR Dashboard 07][nectar-db-07]

It is important at this point to take note of the BTP instance's IP address as 
this will be used for remote desktop access later on using the [NoMachine][nomachine]
remote desktop client. After using the BTP instance, the stack together with its created
resources can be deleted from the dashboard by going to `Orchestration -> Stacks -> Actions -> Delete Stack`.

<!-- WORKSHOP DYNAMIC -->
The `heat` template (`ngs-cfn.yaml`) can also be launched from the command line
using the `python-heatclient`, which interacts with the [NeCTAR API][nectar-api].
To launch the template from the command line, `python-heatclient` must first be
installed and the OpenStack credentials file from the NeCTAR Dashboard downloaded
on the client machine. Source the credentials file:
```
source openrc.sh
```

<!-- WORKSHOP DYNAMIC -->
Then execute the `heat` command with the required parameters. The parameters
listed above when using the template from the NeCTAR Dashboard can be configured
from the command line:
```
heat stack-create -f ngs-cfn.yaml -P "KeyName=cloudcentral;InstanceType=m1.small;InstanceCount=1;ImageName=BTP-2016-01-25;AvailabilityZone=monash-01;TraineePassword=B$dP@ssW0rd" BTP-01
+--------------------------------------+------------+--------------------+---------------------+--------------+
| id                                   | stack_name | stack_status       | creation_time       | updated_time |
+--------------------------------------+------------+--------------------+---------------------+--------------+
| fb25d83f-771b-4bf4-abf7-f9c23186a661 | BTP-01     | CREATE_IN_PROGRESS | 2016-01-26T23:28:14 | None         |
+--------------------------------------+------------+--------------------+---------------------+--------------+
```

In the sample command above, the parameters are supplied after the `-P` flag.
After issuing the `heat` command, it returns the stack information including its
creation status. To check on the status of the created stack, the `heat stack-list`
command can be used. Once the stack has been created, the created resources,
the BTP instance can then be accessed using NoMachine remote desktop.

AWS
---

To launch BTP instances on AWS, a `cloudformation` template compatible with
[AWS CloudFormation][aws-cloudformation] has been developed. This template is
included within the orchestration submodule (this repository) of the BTP workshop
repository. This `cloudformation` template can be used to launch a single BTP instance
from the [AWS Console][aws-console] or using the [AWS CLI][aws-cli]. The following steps
will first highlight how to launch the BTP instance using [AWS Console][aws-console]. 
The BTP workshop repository and its submodules must be cloned first from GitHub
to get the `cloudformation` template:

<!-- WORKSHOP DYNAMIC -->
Clone the BPA-CSIRO BTP NGS workshop repository and its submodules:
```
git clone --recursive https://github.com/BPA-CSIRO-Workshops/btp-workshop-ngs.git
```

Then the user can login to the console:

![AWS Console 01][aws-cs-01]

There's also an option in the console login page to create a new account for new users.
Once logged-in, the main page, providing an overview of all AWS services is presented:

![AWS Console 02][aws-cs-02]

Before using CloudFormation to launch the BTP instance, the user must have a valid `key pair`.
This will be used by the `cloudformation` template for accessing the BTP instance with `sudo`
privileges. From the main console page, click on the `EC2` service. 

![AWS Console 03][aws-cs-03]

From the left panel, access the `NETWORK & SECURITY -> Key Pairs` menu. 
This will bring the keypair page, click on `Create Key Pair`:

![AWS Console 04][aws-cs-04]

Following the prompt on the next page for creating the new keypair. 
It is important to remember the keypair name. This will be used later when launching the
BTP instance using CloudFormation. The CloudFormation service can then be accessed by
going to `Services -> Management Tools -> CloudFormation`:

![AWS Console 05][aws-cs-05]

The CloudFormation page will then be presented, giving a number of options to get started.
Choose (click) the `Create New Stack`:

![AWS Console 06][aws-cs-06]

On the next page, various options are presented for loading the template. 
Choose (click) the `Choose a template` and tick the `Upload a template to Amazon S3`, 
then click on `Choose file`:

![AWS Console 07][aws-cs-07]
<!-- WORKSHOP DYNAMIC -->
Locate where the BTP workshop repository has been cloned, then navigate to the
`orchestration\cloudformation` subdirectory, choose the `ngs.json` template file, 
then click on `Open`:

![AWS Console 08][aws-cs-08]

Once the `ngs.json` file has been loaded into CloudFormation, 
the parameters page will be presented. This is where the required parameters
to launch the BTP instance must be completed. The following parameters are mandatory
for launching the `cloudformation` template: `Stack name`, `InstanceType`, `KeyName`,
`SSHLocation`, and `Trainee Password`.

`Stack name` is simply what string to name the newly created stack. 
`InstanceType` defines the size of the instance to be created, in terms of computational
and storage resources. Note that instance types are charged differently. 
`KeyName` is the name of the keypair to assign to the instance user (ubuntu)
that has `sudo` privileges. `SSHLocation` provides a mechanism to restrict
access to the instance. This option can be set to specific network ranges
so only clients from that range can access the instance. The example below
configures the instance to be accessible from anywhere. Lastly, 
`Trainee Password` is the password to assign the workshop trainee user,
for remote desktop access.

Once these parameters have been completed, click on the `Next` button to progress to the next page. 

![AWS Console 09][aws-cs-09]

Continue going to the next page until the review page is presented.
This page provides a quick summary of the parameters to be used for the
creation of the BTP instance. Once satisfied, click on `Create` to start the orchestration process:

![AWS Console 10][aws-cs-10]

This will direct to the stack status page, in here, the new stack's status can be monitored:

![AWS Console 11][aws-cs-11]

After several minutes, the stack creation will then be completed as stated on its status:

![AWS Console 12][aws-cs-12]

The `cloudformation` template will launch the BTP instance on EC2.
The instance state can be verified by goint to the EC2 service page,
then navigating to `Instances -> Instances` from the left panel:

![AWS Console 13][aws-cs-13]

It'll take several minutes for the BTP instance to be completely operational
after launching it. Training modules datasets are first pulled down from Amazon S3
object storage and stored into the BTP instance's storage device. 
After this is completed, the BTP instance can then be accessed via SSH,
if using the user with administrator access, or via NX remote desktop,
for the trainee user.

Accessing BTP Instances
=======================

The recommended way for accessing the BTP instances is via remote desktop.
NoMachine is configured on the BTP images and remote desktop access is
done using `NX` protocol. Once NoMachine is installed on the client machine,
it can then be launched to start the connection to the BTP instance:

![NX 01][nx-01]

After clicking on `New` button, the new connection configuration is initiated:

![NX 02][nx-02]

`NX` protocol must chosen for the remote desktop connection, 
then click on `Continue` to go to the next panel:

![NX 03][nx-03]

The BTP instance's IP address is then entered into `Host` field, 
using the default `NX` port `4000` as is, then click on `Continue` to go the next panel:

![NX 04][nx-04]

For the authentication method, `Password` is then chosen as the `Trainee Password`
will be used to connect to the BTP instance. Once the password has been entered,
the `Continue` button can then be clicked to advance to the next panel:

![NX 05][nx-05]

The BTP instance will be access directly network-wise, so the `Don't use a proxy`
option is chosen, then click on the `Continue` button to advance to the last configuration panel:

![NX 06][nx-06]

The connection can then be named on the last panel. After a suitable name has been entered,
the `Done` button can be clicked to get back to the main connections page:

![NX 07][nx-07]

By choosing on the now saved connection and clicking on the `Connect` button,
the connection will commence. Once connection to the BTP instance is estabilished,
the login prompt will be presented:

![NX 08][nx-08]

The username configured for the workshop will be `trainee` and the password will
be the one entered for the `Trainee Password` paramater upon launch of the `heat`
template on the NeCTAR Research Cloud orchestration service. Once the username and
password information has been entered, the `OK` button can be clicked to open the
remote desktop session:

![NX 09][nx-09]

Now the BTP instance can be used just like a normal desktop environment. 
Applications and analysis tools can be used and launched just like from a normal desktop:

![NX 10][nx-10]

License
=======
The contents of this repository are released under the Creative Commons
Attribution 3.0 Unported License. For a summary of what this means,
please see: http://creativecommons.org/licenses/by/3.0/deed.en_GB

[packer]: https://www.packer.io/downloads.html
[virtualbox]: http://www.vmware.com/products/fusion/overview.html
[vmware-fusion]: http://www.vmware.com/products/fusion/overview.html
[vmware-workstation]: http://www.vmware.com/products/fusion/overview.html
<!-- WORKSHOP DYNAMIC -->
[btp-ngs-release]: https://github.com/BPA-CSIRO-Workshops/btp-workshop-ngs/releases
[nectar-rc]: https://nectar.org.au/research-cloud/
[nectar-azs]: https://support.rc.nectar.org.au/docs/availability-zones
[nectar-rc-heat]: https://support.rc.nectar.org.au/docs/heat
[nectar-authentication]: https://support.rc.nectar.org.au/docs/authentication
[nectar-dashboard]: https://support.rc.nectar.org.au/docs/dashboard
[nectar-api]: https://support.rc.nectar.org.au/docs/api-clients
[nectar-azs]: https://support.rc.nectar.org.au/docs/availability-zones
[nectar-keypairs]: https://support.rc.nectar.org.au/docs/keypairs
[nectar-resources]: https://support.rc.nectar.org.au/docs/resources-available
[nectar-heat-resources]: https://support.rc.nectar.org.au/docs/heat-supported-resources
[aws]: https://aws.amazon.com/
[aws-console]: https://aws.amazon.com/console/
[aws-cli]: https://aws.amazon.com/cli/
[aws-cloudformation]: https://aws.amazon.com/cloudformation/
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
[aws-cs-01]: images/aws-cs-01.png
[aws-cs-02]: images/aws-cs-02.png
[aws-cs-03]: images/aws-cs-03.png
[aws-cs-04]: images/aws-cs-04.png
[aws-cs-05]: images/aws-cs-05.png
[aws-cs-06]: images/aws-cs-06.png
[aws-cs-07]: images/aws-cs-07.png
[aws-cs-08]: images/aws-cs-08.png
[aws-cs-09]: images/aws-cs-09.png
[aws-cs-10]: images/aws-cs-10.png
[aws-cs-11]: images/aws-cs-11.png
[aws-cs-12]: images/aws-cs-12.png
[aws-cs-13]: images/aws-cs-13.png
[nx-01]: images/nx-01.png
[nx-02]: images/nx-02.png
[nx-03]: images/nx-03.png
[nx-04]: images/nx-04.png
[nx-05]: images/nx-05.png
[nx-06]: images/nx-06.png
[nx-07]: images/nx-07.png
[nx-08]: images/nx-08.png
[nx-09]: images/nx-09.png
[nx-10]: images/nx-10.png
