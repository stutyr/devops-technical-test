terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstates-uksouth-001"
    storage_account_name = "satfstatesdevuks001"
    container_name       = "tfstates"
    key                  = "aks.tfstate"
  }
}