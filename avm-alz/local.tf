locals {
  management_groups_level_1 = {
    sub-management-group-1 = {
      id           = "avm-alz-test-1"
      display_name = "avm-alz-test-management-group"
      parent_id    = "c0c0e8f9-4ab4-4fc8-855f-1c386ad737a3"
    }
  }

  management_groups_level_2 = {
    child-management-group-1 = {
      id           = "child-management-group-1"
      display_name = "Child Management Group 1"
      parent_id    = "avm-alz-test-1"
    },
    child-management-group-2 = {
      id           = "child-management-group-2"
      display_name = "Child Management Group 2"
      parent_id    = "avm-alz-test-1"
    }
  }
}
