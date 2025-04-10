# Setup environment

- [Setup environment](#setup-environment)
  - [Lab overview](#lab-overview)
  - [Objectives](#objectives)
  - [Instructions](#instructions)
    - [Before you start](#before-you-start)
    - [Exercise 1: Deploy an Azure Virtual Machine](#exercise-1-deploy-an-azure-virtual-machine)
      - [Use your existing Resource Group](#use-your-existing-resource-group)
      - [Create an Azure Virtual Machine](#create-an-azure-virtual-machine)
    - [Exercise 2: Remove resources](#exercise-2-remove-resources)

## Lab overview

In this lab, you will learn how to deploy an Azure Virtual Machine.

## Objectives

After you complete this lab, you will be able to:

-   Deploy an Azure Virtual Machine
-   Understand how Terraform manages dependencies.

## Instructions

### Before you start

- Ensure Terraform (version >= 1.0.0) is installed and available from system PATH.
- Ensure Azure CLI is installed.
- Check your access to the Azure Subscription and Resource Group provided for this training.
- Your environment is setup and ready to use from the lab *1-Setup environment*.

### Exercise 1: Deploy an Azure Virtual Machine

#### Use your existing Resource Group

Create a `data.tf` file, and add the following `data` block to reference your Resource Group:

```hcl
data "azurerm_resource_group" "training_rg" {
  name = "your_resource_group_name"
}
```

> Since this Resource Group has been created outside of Terraform, we are using a data block to retrieve its configuration.  
> No change will be done on this Resource Group, this template does not manage its lifecyle.  

#### Create an Azure Virtual Machine

Create a `vm.tf` file, and add the following blocks to create a Virtual Machine:

```hcl
# virtual machine
resource "azurerm_linux_virtual_machine" "vm_training" {
  name                = "vm4agdtftraining"
  resource_group_name  = data.azurerm_resource_group.training_rg.name
  location            = "westeurope"
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "P@ssword01!!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic_training.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"

  }
}

resource "azurerm_network_interface" "nic_training" {
  name                = "example-nic"
  location            = "westeurope"
  resource_group_name  = data.azurerm_resource_group.training_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sn_training.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_subnet" "sn_training" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.training_rg.name
  virtual_network_name = azurerm_virtual_network.vn_training.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_virtual_network" "vn_training" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = "westeurope"
  resource_group_name = data.azurerm_resource_group.training_rg.name
}

```
Terraform resource creation order is determined using implicit and explicit dependencies (explicit dependency is achieved using the attribute `depends_on` - https://www.terraform.io/docs/language/meta-arguments/depends_on.html).  

In this template, resources are intentionally in the wrong order.  
We will see that this does not prevent Terraform from creating resources in the right order (first the virtual network and subnet, next the network interface, and finally the virtual machine).  
Terraform bases its order creation on implicit dependencies, defined with using resources attributes in dependent objects (e.g. the VM using id attribute from the NIC).  


Open a new shell and run the following commands:

```powershell
az login
$env:ARM_SUBSCRIPTION_ID="[Id of the provided training subscription]"
terraform init -backend-config=".\configuration\dev-backend.hcl" [-reconfigure]
terraform plan
```

The plan is indicating four resources to create, which are:
- azurerm_linux_virtual_machine
- azurerm_network_interface
- azurerm_subnet
- azurerm_virtual_network

Run the `apply` command:

```powershell
terraform apply
```

Confirm the creation (*yes* response).  

![vm_creation](../assets/vm_creation.PNG)

Use the Azure portal to confirm resources creation.

### Exercise 2: Remove resources

Run the `destroy` command:

```powershell
terraform destroy
```

Confirm the deletion (*yes* response).

Note:
> `apply` and `destroy` commands accept an `-auto-approve` option to the command line that avoids querying for user validation.  
> This is to be used carefully, e.g. to avoid accidently deleting resources.

Use the Azure portal to confirm resources deletion.

