locals {

  custom_landing_zones_dev_unit = {
    # Production Environment Management Group  
    "${var.root_id}-dev-unit-1" = {
      display_name               = "Unit #1"
      parent_management_group_id = "${var.root_id}-dev"
      subscription_ids           = []
      archetype_config = {
        archetype_id   = "default_empty"
        parameters     = {}
        access_control = {}
      }
    }

    "${var.root_id}-dev-unit-2" = {
      display_name               = "Unit #2"
      parent_management_group_id = "${var.root_id}-dev"
      subscription_ids           = []
      archetype_config = {
        archetype_id   = "default_empty"
        parameters     = {}
        access_control = {}
      }
    }

    "${var.root_id}-dev-unit-3" = {
      display_name               = "Unit #3"
      parent_management_group_id = "${var.root_id}-dev"
      subscription_ids           = []
      archetype_config = {
        archetype_id   = "default_empty"
        parameters     = {}
        access_control = {}
      }
    }
  }
}
