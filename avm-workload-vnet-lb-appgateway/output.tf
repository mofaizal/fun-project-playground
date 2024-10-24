output "vnet_id" {
  value = module.virtualnetwork
}
output "location" {
  value = local.location
}

output "subnet_all" {
  value = module.subnet
}

output "resource_group_name" {
  value = module.resource_group.name
}

