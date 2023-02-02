terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.41.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}

  # subscription_id = "0b19a6e4-c84e-4f7c-88ac-21f4496e80f5"
  # tenant_id       = "76ec0dae-7ff0-4f64-aff4-a70cc0fc2625"
  # client_id       = "528b024e-4b16-4924-aa15-7375c53450cc"
  # client_secret   = "alU8Q~VzX7opa2Bc.QDwasFSg~rsE5YsPov2JcBs"
}


