#!/bin/bash

echo "##############################################################################################"
echo "Welcome to the kubernetes setup on Cloud. Answer the below questions to trigger the automation"
echo "##############################################################################################"

#variables
infraFolder=infrastructure-setup
read -p "Enter your AWS access_key: " access_key
read -s -p "Enter your AWS secret_key: " secret_key
## as -s will not go to new line ##
echo
#if not provided, then default values would be used.
read -p "Enter AWS region you want to use: " region
read -p "Enter EC2 instance type [ t2.medium and above ]: " instance_type

### Functions ###
setTerraformVars () {
    ### Copy file to infrastructure-setup ###
    echo "Copying terraform.tfvars template..."
    cp templates/terraform.txt ${infraFolder}/terraform.tfvars

    sed -i '' "s/region_placeholder/\"${region}\"/g" ${infraFolder}/terraform.tfvars
    sed -i '' "s/access_key_placeholder/\"${access_key}\"/g" ${infraFolder}/terraform.tfvars
    sed -i '' "s/secret_key_placeholder/\"${secret_key}\"/g" ${infraFolder}/terraform.tfvars

    echo "Variable file has been setup..."
}

setEC2instance () {
    echo "Copying ec2-instance.tf template..."
    cp templates/ec2-instance.txt ${infraFolder}/ec2-instance.tf

    sed -i '' "s/instance_type_placeholder/\"${instance_type}\"/g" ${infraFolder}/ec2-instance.tf
    echo "EC2 Instance file has been setup..."
}

initializeTerraform () {
    if [[ ! -e ${infraFolder}/.terraform.lock.hcl  ]]
    then
        echo "Initializing Terraform.."
        cd ${infraFolder}
        terraform init
        cd ..
    else
        lock_file_provider_version=$(cat ${infraFolder}/.terraform.lock.hcl | grep version | awk -F '=' '{ print $2 }' | tr -d '"')
        file_provider_version=$(cat ${infraFolder}/providers.tf | grep version | awk -F '=' '{ print $2 }' | tr -d '"')
        ### Checking provider versions ###
        if [[ ${lock_file_provider_version} == ${file_provider_version} ]]
        then
            cd ${infraFolder}/
            terraform init
            cd ..
        else
            echo "Version has been changed in providers.tf file!"
            read -p "Do you want to upgrade verison or use existing one..?[ yes || no ]" version_upgrade

            if [[ ${version_upgrade} == 'yes' ]]
            then
                echo "Upgrade"
            else
                echo "Rollback the version in providers.tf file"
            fi
        fi
    fi
}

validateTerraform () {
    ### formating the files ###
    cd ${infraFolder}/
    terraform fmt

    ### Validate the code ###
    terraform validate
    ### Check the output and proceed further failure = 1 and success = 0 ###
    if [[ $? == 1 ]]
    then
    ### Stop the script! ###
        echo "Validation failed.."
        exit $?
    else
        cd ..
    fi
}

applyTerraform(){
    cd ${infraFolder}
    terraform apply --auto-approve
    cd ..
    echo "###################################################"
    echo "Infrastructure setup is complete"
    echo "###################################################"
}

planTerraform () {
    echo "#########################"
    echo "Running terraform plan.."
    cd ${infraFolder}/
    terraform plan
    cd ..

    echo "#######################################################################"
    read -p "Are we good to proceed to apply the configuration..? [ yes || no ]: " apply_response

    if [[ ${apply_response} == 'yes' ]]
    then
        applyTerraform
    else
        echo "Exiting.."
        exit 1
    fi
}

setupInventory(){
    echo "Copying the inventory file template"
    cp templates/inventory.txt inventory
    
    ### Get the output from terraform state files for machine IP's ###
    cd ${infraFolder}/
    terraform output > ../temp_ipaddress
    cd ..

    ### Set the variables for updating the inventory file ###
    master_ip=$(cat temp_ipaddress | grep master | awk -F '=' '{ print $2 }' | tr -d '"' | tr -d ' ')
    worker_ip=$(cat temp_ipaddress | grep worker | awk -F '=' '{ print $2 }' | tr -d '"' | tr -d ' ')

    ### Updating the inventory file ###
    echo "Updating the inventory file with master and worker node IP..."
    sed -i '' "s/master_ip_placeholder/${master_ip}/g" inventory
    sed -i '' "s/worker_ip_placeholder/${worker_ip}/g" inventory

    ### SSH into the nodes before runnning the Ansible Role ###
    echo "Waiting for 20 seconds, for the host to get ready"
    sleep 20
    ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no ec2-user@${master_ip} "exit"
    ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no ec2-user@${worker_ip} "exit"

    if [[ $? == 0 ]]
    then
        echo "Able to connect successfully!"
        rm -rf temp_ipaddress
    else
        echo "Connection not successful! Exiting.."
        exit $?
    fi
}

runAnsibleRole () {
    echo "Running the Ansible Role to setup Kubernetes"
    ansible-playbook main.yaml -i inventory
    ## maybe need to check exit code!
    echo $?
    echo "Setup has been completed successfully!"
    echo "Login to master ${master_ip} and start using the cluster"
}


### Start of the program after variables ###

#check if access_key and secret_key are not empty
if [[ -n ${access_key} && -n ${secret_key} ]]
then
    ### Check if region variable is empty ###
    if [[ -z ${region} ]]
    then
        region="ap-south-1"
    fi

    ### Check if instance_type variable is empty ###
    if [[ -z ${instance_type} ]]
    then
        instance_type="t2.medium"
    fi

    ### Setup Terraform Vars file ###
    setTerraformVars
    ### Setup EC2 Instance File ###
    setEC2instance
    ### Initialize Terraform ###
    initializeTerraform
    ### Validate and Format Terraform ###
    validateTerraform
    ### Run Terraform plan ###
    planTerraform

    ### configure inventory file for ansible script ###
    setupInventory
    runAnsibleRole
else
    ### Script Ends ###
    echo "Creds not provided, please try again! Exiting.."
fi