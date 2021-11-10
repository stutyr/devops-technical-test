# Outline build steps for the code deployment

## Overview

The following steps are required to deploy this code to create the web site.  As it depends on a few client applications these will need to be intalled prior to deployment.  The applications required are:

- **Azure CLI** brew update && brew install azure-cli on a Mac

- **Terraform** brew install terraform

NB for the terraform to successfully apply the code the service principal or other authentication method will need the User Access Administrator role assigned within the subscription. 

## Step 1 - deploy IaC via terraform 

1. *cd ./terraform* to go into the folder containing the terraform code

2. add the following into the aks.tf file, or alternatively create a separate tf file (NB during development a provider.tf file was used and this is included within the .gitignore file).  This example assume the use of a service principal but alternate methods are available (see https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret )

  ~~~
  provider "azurerm" {
    features {}
    subscription_id = <ID of subscription used for hosting the IaC>
    tenant_id       = <ID of the Azure tenant>
    client_id       = <ID of the Service Principal with contributor & User Access Administrator roles>
    client_secret   = <Secret for authenticating the Service Principal>
  }
  ~~~

3. Update the **terraform.tfvars** file with the relevant values for your deployment.  The variables are:

 - *service_name*: a short unique identifier that will be used in the resource names.  NB this must be alphanumeric without punctuation marks.

 - *service_number*: used as an appendix to resource names in case multiple instances are required.

 - *service_location*: the azure region used for hosting the resources, which should be specified without spaces e.g.       = "uksouth" rather than "UK South".

- *service_short_location*: a three character string for the location used where there are restrictions on string length (e.g. storage accounts).

4.terraform init

5.terraform plan -input=false (should say there are 7 resource to create on the first running)

6.terraform apply -auto-approve -input=false (should deploy 7 resources)

The terraform apply outputs some key details about connecting to your AKS cluster and also the web site URL published by the storage account.

## Step 2 - build node.js docker image and push to registry before deploying to AKS

- cd ../app

- az acr login --name [ACR name]

- docker build . -t [ACR name].azurecr.io/merchandiseapp:0.0.2

- docker push [ACR name].azurecr.io/merchandiseapp:0.0.2

- az aks get-credentials --name [AKS cluster name] --resource-group [Resource Group name]

- az aks update -n [AKS cluster name] -g [Resource Group name] --attach-acr [ACR name]

- kubectl create namespace merchandise

- kubectl apply -f deployment.yaml && kubectl apply -f service.yaml

- after a few minutes, kubectl get svc --namespace merchandise will display the external IP for the service

## Step 3 - copy static content to azure blob

cd ../web

- edit the index.html file and replace the three occurrences of k8sloadbalancer with the IP address of the K8s service's external IP

- cd ..

- az storage blob upload-batch -s ./web/ -d '$web' --account-name [storage account name]

## Step 4 - Helm chart to install docker image into AKS


*needs further development & not yet ready* 
 
 cd ../helm

helm install merchandise