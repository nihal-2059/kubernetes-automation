read -p "Do you want to delete the infrastructure? [ yes || no ]: " user_response

if [[ ${user_response} == "yes" ]]
then
    cd infrastructure-setup/
    echo "########## Starting deletion of Resources ##########"
    terraform destroy --auto-approve
    cd ..
    
    echo "#####################################################"
    echo "Infrastructure has been deleted successfully!"
    echo "#####################################################"
else
    echo "Wrong choice! Exiting.."
fi