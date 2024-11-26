# resource "azurerm_web_application_firewall_policy" "azure_waf" {
#   location            = azurerm_resource_group.rg_group.location
#   name                = "example-wafpolicy"
#   resource_group_name = azurerm_resource_group.rg_group.name

#   managed_rules {
#     managed_rule_set {
#       version = "3.2"
#       type    = "OWASP"

#       rule_group_override {
#         rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"

#         rule {
#           id      = "920300"
#           action  = "Log"
#           enabled = true
#         }
#         rule {
#           id      = "920440"
#           action  = "Block"
#           enabled = true
#         }
#       }
#     }
#     exclusion {
#       match_variable          = "RequestHeaderNames"
#       selector                = "x-company-secret-header"
#       selector_match_operator = "Equals"
#     }
#     exclusion {
#       match_variable          = "RequestCookieNames"
#       selector                = "too-tasty"
#       selector_match_operator = "EndsWith"
#     }
#   }
#   custom_rules {
#     action    = "Block"
#     priority  = 1
#     rule_type = "MatchRule"
#     name      = "Rule1"

#     match_conditions {
#       operator           = "IPMatch"
#       match_values       = ["192.168.1.0/24", "10.0.0.0/24"]
#       negation_condition = false

#       match_variables {
#         variable_name = "RemoteAddr"
#       }
#     }
#   }
#   custom_rules {
#     action    = "Block"
#     priority  = 2
#     rule_type = "MatchRule"
#     name      = "Rule2"

#     match_conditions {
#       operator           = "IPMatch"
#       match_values       = ["192.168.1.0/24"]
#       negation_condition = false

#       match_variables {
#         variable_name = "RemoteAddr"
#       }
#     }
#     match_conditions {
#       operator           = "Contains"
#       match_values       = ["Windows"]
#       negation_condition = false

#       match_variables {
#         variable_name = "RequestHeaders"
#         selector      = "UserAgent"
#       }
#     }
#   }
#   policy_settings {
#     enabled                     = true
#     file_upload_limit_in_mb     = 100
#     max_request_body_size_in_kb = 128
#     mode                        = "Prevention"
#     request_body_check          = true
#   }
# }
