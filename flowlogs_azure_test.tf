############################################
# flowlogs_azure_test.tf  (single source of truth)
############################################

# Network Watcher (ensure this isn't defined elsewhere)
resource "azurerm_network_watcher" "NetWatcher" {
  name                = "NetworkWatcher_westus"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Random string for storage account (longer + numeric to guarantee global uniqueness)
resource "random_string" "random" {
  length  = 12
  lower   = true
  numeric = true
  upper   = false
  special = false

  # regenerate if RG name changes
  keepers = {
    rg = azurerm_resource_group.rg.name
  }
}

# Storage account for flow logs (globally unique name requirement)
resource "azurerm_storage_account" "flowlogs" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name                = "flow${random_string.random.result}" # must be 3–24 chars, lowercase/numbers only

  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
}

# --------------------------
# VNet Flow Log for vnetA
# --------------------------
resource "azurerm_network_watcher_flow_log" "vnetA_flowlog" {
  name                 = "vnetA-flow-logs"
  network_watcher_name = azurerm_network_watcher.NetWatcher.name
  resource_group_name  = azurerm_network_watcher.NetWatcher.resource_group_name
  location             = azurerm_network_watcher.NetWatcher.location

  target_resource_id = azurerm_virtual_network.vnetA.id
  storage_account_id = azurerm_storage_account.flowlogs.id
  enabled            = true
  version            = 2

  retention_policy {
    enabled = true
    days    = 30 # adjust as needed (1–365)
  }

  # Optional: Traffic Analytics
  # traffic_analytics {
  #   enabled               = true
  #   workspace_id          = azurerm_log_analytics_workspace.law.workspace_id
  #   workspace_region      = azurerm_log_analytics_workspace.law.location
  #   workspace_resource_id = azurerm_log_analytics_workspace.law.id
  #   interval_in_minutes   = 10
  # }
}

# --------------------------
# VNet Flow Log for vnetB
# --------------------------
resource "azurerm_network_watcher_flow_log" "vnetB_flowlog" {
  name                 = "vnetB-flow-logs"
  network_watcher_name = azurerm_network_watcher.NetWatcher.name
  resource_group_name  = azurerm_network_watcher.NetWatcher.resource_group_name
  location             = azurerm_network_watcher.NetWatcher.location

  target_resource_id = azurerm_virtual_network.vnetB.id
  storage_account_id = azurerm_storage_account.flowlogs.id
  enabled            = true
  version            = 2

  retention_policy {
    enabled = true
    days    = 30 # adjust as needed (1–365)
  }

  # Optional: Traffic Analytics
  # traffic_analytics { ... }
}
