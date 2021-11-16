
# --------------------------------------------------------------------------
# This terraform file creates the following resource group containing
#  1. 1 node AKS cluster for hosting the node.js app
#  2. Azure container registry for hosting the docker container for the nod.js app
#  3. Azure storage account with static web hosting of the html based front end
# --------------------------------------------------------------------------

# --------------------------------------------------------------------------
# Local variable setup
# --------------------------------------------------------------------------

locals {
  env_resource_name        = "${var.service_name}-${var.service_location}-${var.service_number}"
  env_resource_short_name  = "${var.service_name}${var.service_short_location}${var.service_number}"
  default_tags = {
    Service     = var.service_name
    Environment = "Production"
    Owner       = "Stuart Tyrrell"
    Deploy_date = timestamp()
  }
}

# --------------------------------------------------------------------------
# Resource Group setup
# --------------------------------------------------------------------------
provider "azurerm" {
  features {} 
}
resource "azurerm_resource_group" "rg001" {
  name                 = "rg-${local.env_resource_name}"
  location             = var.service_location
  tags                 = "${local.default_tags}"
}

# --------------------------------------------------------------------------
# AKS Setup
# --------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "aks001" {
  name                 = "aks-${local.env_resource_name}"
  location             = azurerm_resource_group.rg001.location
  resource_group_name  = azurerm_resource_group.rg001.name
  dns_prefix           = var.service_name
  kubernetes_version   = "1.21.2"
  default_node_pool {
    name                 = "default"
    node_count           = 1
    vm_size              = "Standard_D2_v2"
  }

  identity {
    type                 = "SystemAssigned"
    
  }

  tags                 = "${local.default_tags}"
}

// output "client_certificate" {
//   value                  = azurerm_kubernetes_cluster.aks001.kube_config.0.client_certificate
// }

// output "kube_config" {
//   value                  = azurerm_kubernetes_cluster.aks001.kube_config_raw
//   sensitive              = true
// }




# --------------------------------------------------------------------------
# ACR Setup
# --------------------------------------------------------------------------

resource "azurerm_container_registry" "acr001" {
  name                 = "acr${local.env_resource_short_name}"
  resource_group_name  = azurerm_resource_group.rg001.name
  location             = azurerm_resource_group.rg001.location
  sku                  = "Standard"
  admin_enabled        = true
  tags                 = "${local.default_tags}"
}

// resource "azurerm_user_assigned_identity" "uai001" {
//   name                 = "uai-${local.env_resource_name}"
//   resource_group_name  = azurerm_resource_group.rg001.name
//   location             = azurerm_resource_group.rg001.location
// }

// resource "azurerm_role_assignment" "acr-user-pull" {
//   scope                = azurerm_container_registry.acr001.id
//   role_definition_name = "acrpull"
//   principal_id         = azurerm_user_assigned_identity.uai001.principal_id
// }


# --------------------------------------------------------------------------
# Storage Account Setup
# --------------------------------------------------------------------------

resource "azurerm_storage_account" "static_storage" {
  name                       = "sa${local.env_resource_short_name}"
  resource_group_name        = azurerm_resource_group.rg001.name
  location                   = azurerm_resource_group.rg001.location
  account_kind               = "StorageV2"
  account_tier               = "Standard"
  account_replication_type   = "LRS"
  enable_https_traffic_only  = true

  static_website {
    index_document = "index.html"
  }

  tags                       = "${local.default_tags}"
}


output "web_site_address" {
  value = azurerm_storage_account.static_storage.primary_web_endpoint
}

output "container_registry" {
  value = azurerm_container_registry.acr001.name
}

output "web_copy_files" {
  value = "az storage blob upload-batch -s ./web/ -d '$web' --account-name ${azurerm_storage_account.static_storage.name}"
}

output "aks_login" {
  value                  = "az aks get-credentials --name ${azurerm_kubernetes_cluster.aks001.name} --resource-group ${azurerm_resource_group.rg001.name}"
}
output "aks_attach_acr" {
  value                  = "az aks update -n ${azurerm_kubernetes_cluster.aks001.name} -g ${azurerm_resource_group.rg001.name} --attach-acr ${azurerm_container_registry.acr001.name}"
}
