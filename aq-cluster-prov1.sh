# change directory
cd ./terraform

# set up all our variables from the last lab, so we can utilize the networking infrastructure that was set up.
export TF_VAR_prefix=$PREFIX
export TF_VAR_resource_group=$RG
export TF_VAR_location=$LOC
export TF_VAR_client_id=$APPID
export TF_VAR_client_secret=$PASSWORD
export TF_VAR_azure_subnet_id=$(az network vnet subnet show -g $RG --vnet-name $VNET_NAME --name $AKSSUBNET_NAME --query id -o tsv)
export TF_VAR_azure_aag_subnet_id=$(az network vnet subnet show -g $RG --vnet-name $VNET_NAME --name $APPGWSUBNET_NAME --query id -o tsv)
export TF_VAR_azure_subnet_name=$APPGWSUBNET_NAME
export TF_VAR_azure_aag_name=$AGNAME
export TF_VAR_azure_aag_public_ip=$(az network public-ip show -g $RG -n $AGPUBLICIP_NAME --query id -o tsv)
export TF_VAR_azure_vnet_name=$VNET_NAME 
export TF_VAR_github_organization=Arturoqu77 # PLEASE NOTE: This should be your github username if you forked the repository.
export TF_VAR_github_token=<use previously created PAT token>
export TF_VAR_aad_server_app_id=<ask_instructor>
export TF_VAR_aad_server_app_secret=<ask_instructor>
export TF_VAR_aad_client_app_id=<ask_instructor>
export TF_VAR_aad_tenant_id=<ask_instructor>