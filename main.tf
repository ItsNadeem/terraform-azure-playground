# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_ref" {
  name     = "test-resource-group"
  location = "westus2"
}


resource "azurerm_application_insights" "app_insights_ref" {
  name                = "tf-test-appinsights"
  location            = azurerm_resource_group.rg_ref.location
  resource_group_name = azurerm_resource_group.rg_ref.name
  application_type    = "web"
}

resource "azurerm_app_configuration" "appconfig" {
  name                = "tf-test-appconfig"
  resource_group_name = azurerm_resource_group.rg_ref.name
  location            = azurerm_resource_group.rg_ref.location
}

output "instrumentation_key" {
  value = azurerm_application_insights.app_insights_ref.instrumentation_key
}

output "app_id" {
  value = azurerm_application_insights.app_insights_ref.app_id
}