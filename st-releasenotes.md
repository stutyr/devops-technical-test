#Stuart Tyrrell's release notes

## Deployment steps

The code contained within this repository will create a basic one node AKS cluster with an ACR to host the container image and a Storage account to host the static content.  

Currently this is not integrated with a CI/CD pipeline and will require a local terraform installation.  To protect the secrets, the azurerm provider is not included with the code and will need to be defined with the relevant service principal or other details to deploy into an azure subscription

1. Deploy terraform by changing to the terraform folder, and running **terraform init**, then **terraform plan** to confirm the resources it will create before running **terraform apply** to deploy the code
## Development steps

- **V0.0.1:** initial step is to create kubernetes cluster plus storage for static hosting.  Azure Container Instances or AWS Fargate were potential for a single container deployment, but requirement specifically asked for Kubernetes cluster.  To enable container deployment a container registry will also be required.

- **V0.0.2** add dockerfile to put node code into a container and push to registry. Code to deploy the static content to the storage account.  Helm chart to deploy to AKS

## Technical Debt

The following section details potential improvements as they are found to enable further development

- use the azure application gateway for ingress.

- deliver  web site via CDN and HTTPS. will require custom domain plus SSL cert.

- make deployment suitable for multi region.

