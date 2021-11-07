#Stuart Tyrrell's release notes

## Development steps

- **V0.0.1:** initial step is to create kubernetes cluster plus storage for static hosting.  Azure Container Instances or AWS Fargate were potential for a single container deployment, but requirement specifically asked for Kubernetes cluster.  To enable container deployment a container registry will also be required.

- **V0.0.2** add dockerfile to put node code into a container and push to registry.

## Technical Debt

The following section details potential improvements as they are found to enable further development

- use the azure application gateway for ingress.

- deliver  web site via CDN and HTTPS. will require custom domain plus SSL cert.

- make deployment suitable for multi region.
