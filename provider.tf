terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "49fa5565-76d0-4070-af99-cd92822edbdc"
  tenant_id       = "7a4b05fe-967b-4634-b55c-ff833ff39e94"

  features {

  }
}

