terraform {
  # AzureRM v4 requires newer Terraform; 1.6+ is a safe floor.
  required_version = ">= 1.6.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.5"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      # Use v4; pin to <5 to avoid breaking changes later.
      version = ">= 4.0.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "testdrive"
  location = "West US"

  tags = {
    environment = "Production"
  }
}
