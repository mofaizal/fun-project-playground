locals {

  custom_landing_zones_non_prod_unit = {
    # Production Environment Management Group  
    "${var.root_id}-non-prod-unit-1" = {
      display_name               = "Unit #1"
      parent_management_group_id = "${var.root_id}-non-prod"
      subscription_ids           = []
      archetype_config = {
        archetype_id   = "default_empty"
        parameters     = {}
        access_control = {}
      }
    }

    "${var.root_id}-non-prod-unit-2" = {
      display_name               = "Unit #2"
      parent_management_group_id = "${var.root_id}-non-prod"
      subscription_ids           = []
      archetype_config = {
        archetype_id   = "default_empty"
        parameters     = {}
        access_control = {}
      }
    }
  }
}
