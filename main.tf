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

resource "azurerm_logic_app_workflow" "logic_app_workflow_ref" {
  name                = "tf-logic-app-workflow"
  location            = azurerm_resource_group.rg_ref.location
  resource_group_name = azurerm_resource_group.rg_ref.name
}

resource "azurerm_logic_app_trigger_http_request" "logic_trigger_http_request" {
  name         = "tf-http-trigger"
  logic_app_id = azurerm_logic_app_workflow.logic_app_workflow_ref.id

  schema = <<SCHEMA
{
    "type": "object",
    "properties": {
        "hello": {
            "type": "string"
        }
    }
}
SCHEMA

}


resource "azurerm_storage_account" "storage_acct" {
  name                     = "teststorageacct101"
  resource_group_name      = azurerm_resource_group.rg_ref.name
  location                 = azurerm_resource_group.rg_ref.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "service_plan" {
  name                = "tf-service-plan"
  location            = azurerm_resource_group.rg_ref.location
  resource_group_name = azurerm_resource_group.rg_ref.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "function_app" {
  name                       = "tf-function-app"
  location                   = azurerm_resource_group.rg_ref.location
  resource_group_name        = azurerm_resource_group.rg_ref.name
  app_service_plan_id        = azurerm_app_service_plan.service_plan.id
  storage_account_name       = azurerm_storage_account.storage_acct.name
  storage_account_access_key = azurerm_storage_account.storage_acct.primary_access_key
}

resource "azurerm_frontdoor" "frontdoor" {
  name                                         = "tf-frontdoor"
  location                                     = azurerm_resource_group.rg_ref.location
  resource_group_name                          = azurerm_resource_group.rg_ref.name
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name               = "exampleRoutingRule1"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["exampleFrontendEndpoint1"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "exampleBackendBing"
    }
  }

  backend_pool_load_balancing {
    name = "exampleLoadBalancingSettings1"
  }

  backend_pool_health_probe {
    name = "exampleHealthProbeSetting1"
  }

  backend_pool {
    name = "exampleBackendBing"
    backend {
      host_header = "www.bing.com"
      address     = "www.bing.com"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "exampleLoadBalancingSettings1"
    health_probe_name   = "exampleHealthProbeSetting1"
  }

  frontend_endpoint {
    name                              = "exampleFrontendEndpoint1"
    host_name                         = "example-FrontDoor.azurefd.net"
    custom_https_provisioning_enabled = false
  }
}


output "instrumentation_key" {
  value = azurerm_application_insights.app_insights_ref.instrumentation_key
}

output "app_id" {
  value = azurerm_application_insights.app_insights_ref.app_id
}