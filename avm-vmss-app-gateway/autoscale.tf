# create autoscale resource that will decrease the number of instances if the azurerm_orchestrated_scale set cpu usaae is below 10% for 2 minutes
resource "azurerm_monitor_autoscale_setting" "autoscale" {
    name                = "autoscale"
 resource_group_name = local.resource_group_name
  location            = local.location
  target_resource_id  = module.terraform_azurerm_avm_res_compute_virtualmachinescaleset.resource_id
  enabled             = true
  tags                = local.tags

  profile {
    name = "autoscale"

    capacity {
      default = 2
      maximum = 10
      minimum = 2
    }
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = module.terraform_azurerm_avm_res_compute_virtualmachinescaleset.resource_id
        operator           = "LessThan"
        statistic          = "Average"
        threshold          = 10
        time_aggregation   = "Average"
        time_grain         = "PT1M"
        time_window        = "PT2M"
      }
      scale_action {
        cooldown  = "PT1M"
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
      }
    }
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = module.terraform_azurerm_avm_res_compute_virtualmachinescaleset.resource_id
        operator           = "GreaterThan"
        statistic          = "Average"
        threshold          = 90
        time_aggregation   = "Average"
        time_grain         = "PT1M"
        time_window        = "PT2M"
      }
      scale_action {
        cooldown  = "PT1M"
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
      }
    }
  }
  predictive {
    scale_mode      = "Enabled"
    look_ahead_time = "PT5M"
  }
}