# This is the module call

resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = local.resource_group_name
}

module "avm-keyvault" {

  source                        = "Azure/avm-res-keyvault-vault/azurerm"
  version                       = "0.9.1"
  name                          = module.naming.key_vault.name_unique
  location                      = local.location
  resource_group_name           = local.resource_group_name
  tenant_id                     = data.azurerm_client_config.this.tenant_id
  public_network_access_enabled = true
  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.dns_zone.id]
      subnet_resource_id            = module.subnet["apptier"].resource_id
    }
  }

  network_acls = {
    bypass   = "AzureServices"
    ip_rules = ["${data.http.ip.response_body}/32"]

  }

  legacy_access_policies_enabled = true
  legacy_access_policies = {
    test = {
      object_id = data.azurerm_client_config.this.object_id
      certificate_permissions = [
        "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"
      ]
      key_permissions = [
        "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey"
      ]
      secret_permissions = [
        "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
      ]
      #   storage_permissions = [
      #     "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
      #   ]

    }
  }

}

data "http" "ip" {
  url = "https://api.ipify.org/"
  retry {
    attempts     = 5
    max_delay_ms = 1000
    min_delay_ms = 500
  }
}

resource "azurerm_key_vault_access_policy" "appag_key_vault_access_policy" {
  key_vault_id = module.avm-keyvault.resource_id
  object_id    = azurerm_user_assigned_identity.appag_umid.principal_id
  tenant_id    = data.azurerm_client_config.this.tenant_id
  secret_permissions = [
    "Get",
  ]
}

resource "azurerm_key_vault_certificate" "ssl_cert_id" {
  key_vault_id = module.avm-keyvault.resource_id
  name         = "app-gateway-cert"

  certificate {
    contents = filebase64("./ssl_cert_generate/certificate.pfx")
    password = "terraform-avm"
  }
  certificate_policy {
    issuer_parameters {
      name = "Unknown"
    }
    key_properties {
      exportable = true
      key_type   = "RSA"
      reuse_key  = true
      key_size   = 2048
    }
    secret_properties {
      content_type = "application/x-pkcs12"
    }
    lifetime_action {
      action {
        action_type = "EmailContacts"
      }
      trigger {
        days_before_expiry = 10
      }
    }
  }
}

resource "azurerm_user_assigned_identity" "appag_umid" {
  location            = local.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = local.resource_group_name

}
