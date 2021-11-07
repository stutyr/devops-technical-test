
# --------------------------------------------------------------------------
# This terraform file creates the following resource group containing
#  1. 1 node AKS cluster for hosting the node.js app
#  2. Azure container registry for hosting the docker container for the nod.js app
#  3. Azure storage account with static web hosting of the html based front end
# --------------------------------------------------------------------------

# --------------------------------------------------------------------------
# Resource Group setup
# --------------------------------------------------------------------------

resource "azurerm_resource_group" "delio-merch" {
  name     = "rg-${var.service_name}-${var.service_location}-${var.service_number}"
  location = var.service_location

  tags = {
    Service = "Merchandise"
    Environment = "Production"
  }
}

# --------------------------------------------------------------------------
# AKS Setup
# --------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "delio-merch" {
  name                = "aks-${var.service_name}-${var.service_location}-${var.service_number}"
  location            = azurerm_resource_group.delio-merch.location
  resource_group_name = azurerm_resource_group.deliomerch.name
  dns_prefix          = "delio-merchandise"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Service = "Merchandise"
    Environment = "Production"
  }
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.delio-merch.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.delio-merch.kube_config_raw

  sensitive = true
}

# --------------------------------------------------------------------------
# ACR Setup
# --------------------------------------------------------------------------

resource "azurerm_container_registry" "acr" {
  name                     = local.container_registry_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = "Standard"
  admin_enabled            = false
}

resource "azurerm_user_assigned_identity" "acr-ident" {
  resource_group_name  = azurerm_resource_group.delio-merch.name
  location             = azurerm_resource_group.delio-merch.location
  name                 = "uai-${var.service_name}-${var.service_location}-${var.service_number}"
}

resource "azurerm_role_assignment" "acr-pull" {
  scope                = data.azurerm_container_registry.delio-acr.id
  role_definition_name = "acrpull"
  principal_id         = azurerm_user_assigned_identity.delio-ident.principal_id
}

# --------------------------------------------------------------------------
# Storage Account Setup
# --------------------------------------------------------------------------
