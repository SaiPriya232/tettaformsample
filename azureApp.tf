terraform {
  required_providers {
    azurerm = {
      version = ">=2.76.0"
    }
    random = {
      version = "3.1.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "priya" {
  name     = "terraform"
  location = "East US"
}

resource "azurerm_virtual_network" "priya" {
  name                = "priya-vnet"
  location            = azurerm_resource_group.priya.location
  resource_group_name = azurerm_resource_group.priya.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "priya" {
  name                 = "priya-subnet"
  resource_group_name  = azurerm_resource_group.priya.name
  virtual_network_name = azurerm_virtual_network.priya.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "Microsoft.Web.hostingEnvironments"
    service_delegation {
      name    = "Microsoft.Web/hostingEnvironments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_app_service_environment_v3" "priya" {
  name                = "priya-asev3"
  resource_group_name = azurerm_resource_group.priya.name
  subnet_id           = azurerm_subnet.priya.id

  internal_load_balancing_mode = "Web, Publishing"

  cluster_setting {
    name  = "DisableTls1.0"
    value = "1"
  }

  cluster_setting {
    name  = "InternalEncryption"
    value = "true"
  }

  cluster_setting {
    name  = "FrontEndSSLCipherSuiteOrder"
    value = "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
  }

  tags = {
    env         = "production"
    terraformed = "true"
  }
}
