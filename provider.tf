terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}


provider "azurerm" {
  subscription_id = "f14b2ec6-1b20-4c56-8ca8-d1f7a23a73cd"
  tenant_id       = "1856c5f7-0771-4489-a163-b2b346c56e20"

  features {

  }
}

