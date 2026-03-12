
vnet_to_create = {
  vnet1 = {
    location      = "westeurope"
    address_space = "10.0.1.0/24"
    subnets = {
      subnet1 = {
        subnet_name             = "subnet1"
        subnet_address_prefixes = ["10.0.1.0/26"]
        
      },
      subnet2 = {
        subnet_name             = "subnet2"
        subnet_address_prefixes = ["10.0.1.64/26"]
        
      }
    }
  },
  vnet2 = {
    location      = "eastus"
    address_space = "10.0.2.0/24"
    subnets = {
      subnet1 = {
        subnet_name             = "subnet1"
        subnet_address_prefixes = ["10.0.2.0/26"]
        
      },
      subnet2 = {
        subnet_name             = "subnet2"
        subnet_address_prefixes = ["10.0.2.64/26"]
        
      }
    }
  },
  vnet3 = {
    location      = "westus"
    address_space = "10.0.3.0/24"
    subnets = {
      subnet1 = {
        subnet_name             = "subnet1"
        subnet_address_prefixes = ["10.0.3.0/26"]
        
      },
      subnet2 = {
        subnet_name             = "subnet2"
        subnet_address_prefixes = ["10.0.3.64/26"]
        
      },
      subnet3 = {
        subnet_name             = "subnet3"
        subnet_address_prefixes = ["10.0.3.128/26"]
        
      },
      subnet4 = {
        subnet_name             = "subnet4"
        subnet_address_prefixes = ["10.0.3.192/26"]
        
      }
    }
  }
}

hub_subnets = {
  subnet1 = {
    subnet_name              = "subnet1"
    subnet_address_prefixes = ["10.0.0.0/26"]
  },
    subnet2 = {
        subnet_name              = "subnet2"
        subnet_address_prefixes = ["10.0.0.64/26"]
    }
}