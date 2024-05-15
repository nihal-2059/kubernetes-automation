# Deploy Kubeadm based Kubernetes cluster on AWS

## Problem at hand!
Recently we have multiple options to setup kubernetes cluster. But to practise for Kubernetes exams and even for understanding the core of Kubernetes the best implementation would be to deploy Kubeadm based cluster. But setting up the infrastructure and then setting up Kubeadm based cluster does take up lot of time.

## Here to fix the problem!
This automation is to spin up kubeadm based cluster on AWS within **MINUTES**. The script will setup **AWS infrastructure** like EC2 instance, security groups, keys to login to machine. Once the infrastructure is setup, next it will also deploy the cluster for you!
So let's dive into the details and see how easy it is to deploy Kubeadm based cluster.

## Tested ON
This has been tested on MAC.
Steps for Linux are bit different, please read the details below.

## Pre-requisites
Install following tools,</br>
Terraform -- https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli </br>
Ansible   -- https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html </br>



Once the above tools are being installed, we can move onto the actual script.

## Let's go throught the Setup now! ( Mac Setup )
1. Once you run the script, it will ask for **credentials**. So first create the IAM user and generate keys!</br>
```IAM --> Create User --> Provide the name --> Permission --> FullAdministrator --> Create```</br>
Then you will have to click on the User --> Security Credentials --> Create Access Key.</br>
Store the **Access** and **Secret** keys as you would not be able to get them back.

2. Generate ssh keys as we would need them to interact with the EC2 instances. </br>
They are usually present in your HOME directory under folder **.ssh** . If you are not able to see them, then please generate them using the ```ssh-keygen command```. Once generated, move the file named ```id_rsa.pub``` to **infrastructure-setup** folder.

3. Once you get the credentials, run the bash script named setup.sh </br>
   ``` bash setup.sh ``` </br>
That's pretty much you will have to do. There are multiple constraints in the script to handle failures. **Please** provide **valid** values, else script will fail.

4. Next it will prompt you to check if the terraform plan has generated the correct plan. If you know terraform you can review it, else just say **yes** at the prompt and the script will proceed further.

5. Once the Infrastructure is setup, it will run the **Ansible role** named **kubernetes-setup** to configure the Kubeadm cluster. You don't have to worry about the **Inventory** file it will be generated dynamically.

6. If all goes good, Kubeadm cluster would be setup and it would provide you the Master Node IP. Just login, </br>
   ``` ssh ec2-user@<masternode-ip> ``` </br>
   Switch to **root** user and run the **kubectl** command and **BOOM** you are good to go!
   

Note : I know we can use provisioners in Terraform, but it's deprecated and not recommended by Terraform. So this script takes care of everything!

## Destroy the resources once done playing with Cluster
1. Just run the script **destroy.sh** </br>
``` bash destroy.sh ```

## Hope you like it and have fun working with cluster and deploying the workloads for testing!

## Setup for Linux machine,
1. Build the docker image using the Dockerfile provided, 
``` docker build -t <username>/<image-name>:<version> . ```

Using the above format, so that you can push the image to docker hub later.

## Pending further configurations for Linux.
