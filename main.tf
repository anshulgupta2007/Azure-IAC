provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "iac-challenge-rg"
  location = "Australia East"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "iac-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "public" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "private" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_storage_account" "storage" {
  name                     = "iacstorageacct999"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  cors_rule {
    allowed_headers    = ["*"]
    allowed_methods    = ["GET", "POST"]
    allowed_origins    = ["*"]
    exposed_headers    = ["*"]
    max_age_in_seconds = 3600
  }
}

resource "azurerm_app_service_plan" "app_plan" {
  name                = "iac-appserviceplan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "webapp" {
  name                = "iac-webapp999"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_plan.id

  site_config {
    always_on = true
  }
}

resource "azurerm_sql_server" "sql" {
  name                         = "iacsqlserver999"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = "YourP@ssword1234"
}

resource "azurerm_sql_database" "sqldb" {
  name                = "iac-sqldb"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sql.name
  sku_name            = "S0"
}

# Optional Monitoring
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "cpu-high-alert"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_app_service.webapp.id]
  description         = "Alert if CPU > 80%"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  frequency = "PT5M"
  window_size = "PT5M"
  severity = 2
  enabled  = true
}

