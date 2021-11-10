# Change Log

## Overview

This page details the development history and potential future improvements.

## Versions


- **V0.0.1:** initial step is to create kubernetes cluster plus storage for static hosting.  Azure Container Instances or AWS Fargate have potential for a single container deployment, but requirement specifically asked for Kubernetes cluster.  To enable container deployment a container registry will also be required.

- **V0.0.2** add dockerfile to put node code into a container and push to registry. Code to deploy the static content to the storage account.  Kubernetes manifest to create the deployment and then expose as a service to the outside world

## Technical Debt

The following section details potential improvements as they are found to enable further development

- use the azure application gateway for ingress.

- deliver  web site via CDN and HTTPS. will require custom domain plus SSL cert.

- make deployment suitable for multi region.

- use helm charts to package up the kubernetes manifests


