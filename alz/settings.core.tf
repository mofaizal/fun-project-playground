locals {

  custom_landing_zones = {

    "${var.root_id}-self-manage" = {
      display_name               = "Self Manage"
      parent_management_group_id = "${var.root_id}"
      subscription_ids           = []
      archetype_config = {
        archetype_id   = "default_empty"
        parameters     = {}
        access_control = {}
      }
    }

    # Production Environment Management Group  
    "${var.root_id}-prod" = {
      display_name               = "Prod"
      parent_management_group_id = "${var.root_id}-landing-zones"
      subscription_ids           = []
      archetype_config = {
        archetype_id = "prod"
        parameters = {
          Deny-Resource-Locations = {
            listOfAllowedLocations = ["southeastasia", ]
          }
          Deny-RSG-Locations = {
            listOfAllowedLocations = ["southeastasia", ]
        } }
        access_control = {}
      }
    }
    # # Production Environment Management Group  
    # "${var.root_id}prod-unit-1" = {
    #   display_name               = "Unit #1"
    #   parent_management_group_id = "${var.root_id}-prod"
    #   subscription_ids           = []
    #   archetype_config = {
    #     archetype_id   = "default_empty"
    #     parameters     = {}
    #     access_control = {}
    #   }
    # }

    # "${var.root_id}prod-unit-2" = {
    #   display_name               = "Unit #2"
    #   parent_management_group_id = "${var.root_id}-prod"
    #   subscription_ids           = []
    #   archetype_config = {
    #     archetype_id   = "default_empty"
    #     parameters     = {}
    #     access_control = {}
    #   }
    # }

    # NON-Production Environment Management Group  
    "${var.root_id}-non-prod" = {
      display_name               = "Non-Prod"
      parent_management_group_id = "${var.root_id}-landing-zones"
      subscription_ids           = []
      archetype_config = {
        archetype_id = "nonprod"
        parameters = {
          Deny-Resource-Locations = {
            listOfAllowedLocations = ["southeastasia", ]
          }
          Deny-RSG-Locations = {
            listOfAllowedLocations = ["southeastasia", ]
          }
        }
        access_control = {}
      }
    }
    # "${var.root_id}-non-prod-unit-1" = {
    #   display_name               = "Unit #1"
    #   parent_management_group_id = "${var.root_id}-non-prod"
    #   subscription_ids           = []
    #   archetype_config = {
    #     archetype_id   = "default_empty"
    #     parameters     = {}
    #     access_control = {}
    #   }
    # }

    # "${var.root_id}-non-prod-unit-2" = {
    #   display_name               = "Unit #2"
    #   parent_management_group_id = "${var.root_id}-non-prod"
    #   subscription_ids           = []
    #   archetype_config = {
    #     archetype_id   = "default_empty"
    #     parameters     = {}
    #     access_control = {}
    #   }
    # }

    # Development Environment Management Group
    "${var.root_id}-dev" = {
      display_name               = "Dev"
      parent_management_group_id = "${var.root_id}-landing-zones"
      subscription_ids           = []
      archetype_config = {
        archetype_id = "default_empty"
        parameters = {
          Deny-Resource-Locations = {
            listOfAllowedLocations = ["southeastasia", ]
          }
          Deny-RSG-Locations = {
            listOfAllowedLocations = ["southeastasia", ]
          }
        }
        access_control = {}
      }
    }
    # "${var.root_id}-dev-unit-1" = {
    #   display_name               = "Unit #1"
    #   parent_management_group_id = "${var.root_id}-dev"
    #   subscription_ids           = []
    #   archetype_config = {
    #     archetype_id   = "default_empty"
    #     parameters     = {}
    #     access_control = {}
    #   }
    # }

    # "${var.root_id}-dev-unit-2" = {
    #   display_name               = "Unit #2"
    #   parent_management_group_id = "${var.root_id}-dev"
    #   subscription_ids           = []
    #   archetype_config = {
    #     archetype_id   = "default_empty"
    #     parameters     = {}
    #     access_control = {}
    #   }
    # }
  }
}
