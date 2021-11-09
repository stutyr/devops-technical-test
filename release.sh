# The following shell file has the outline build steps for the code deployment



# Step 1 - deploy IaC via terraform 
cd ./terraform
terraform init
terraform plan -input=false
terraform apply -auto-approve -input=false

# Step 2 - copy static content to azurte blob 
cd ..
az storage blob upload-batch -s ./web/ -d '$web' --account-name <storage-account-name>

# Step 3 - build node.js docker image and push to registry
cd ../app
docker build . -t xxx.azurecr.io/merchandisesite:0.0.2
docker push xxx.azurecr.io/merchandisesite:0.0.2

# Step 4 - Helm chart to install docker image into AKS
cd ../helm
helm install merchandise