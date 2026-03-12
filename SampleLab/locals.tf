

locals {
  SubnetsList = flatten([for vnet_key, vnet_value in var.vnet_to_create :
    [for k, v in vnet_value.subnets : {
      vnet_key                = vnet_key
      subnet_name             = "${vnet_key}-${v.subnet_name}"
      subnet_address_prefixes = v.subnet_address_prefixes
  }]])
  
  SubnetsMap = { for i in local.SubnetsList :
    i.subnet_name => {
      vnet_key                = i.vnet_key
      subnet_name             = i.subnet_name
      subnet_address_prefixes = i.subnet_address_prefixes

    }
  }

  
}
