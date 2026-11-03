# Create Module

Table of Contents
=================

- [Create Module](#create-module)
- [Table of Contents](#table-of-contents)
  - [Lab overview](#lab-overview)
  - [Objectives](#objectives)
  - [Instructions](#instructions)
    - [Before you start](#before-you-start)
    - [Exercise 1: Create and consume a module for Storage Account](#exercise-1-create-and-consume-a-module-for-storage-account)
    - [Use your existing Resource Group](#use-your-existing-resource-group)
      - [Create the tree hierarchy for the module](#create-the-tree-hierarchy-for-the-module)
      - [Define the module resources](#define-the-module-resources)
      - [Consume the module](#consume-the-module)
    - [Exercise 2: Use module outputs](#exercise-2-use-module-outputs)
    - [Exercise 3: Remove resources](#exercise-3-remove-resources)

## Lab overview

In this lab, you will learn how to create and consume a module.  
The module will create a Storage Account and a blob container.  
It will take as input the name of the Resource Group, the name of the storage (and will add a prefix and a suffix) and the name of the blob container.  
It will output the final name of the storage.

## Objectives

After you complete this lab, you will be able to:

- Create a module to manage Storage Account
- Understand how to use Terraform modules

## Instructions

### Before you start

- Ensure Terraform (version ~> 1.13.0) is installed and available from system PATH.
- Ensure Azure CLI is installed.
- Check your access to the Azure Subscription and Resource Group provided for this training.
- Your environment is setup and ready to use from the lab *1-Setup environment*.

### Exercise 1: Create and consume a module for Storage Account

### Use your existing Resource Group

Create a `data.tf` file, and add the following `data` block to reference your Resource Group:

```hcl
data "azurerm_resource_group" "rg_training" {
  name = "your_resource_group_name"
}
```

> Since this Resource Group has been created outside of Terraform, we are using a data block to retrieve its configuration.  
> Using a `data` block protects from bringing changes to the resource: current Terrafrom template file doesn't manage the resource group lifecyle. No change will be done on this Resource Group.

#### Create the tree hierarchy for the module

From the root folder create a **modules** folder and add a **storageaccount** sub-directory:

```bash
cd <root folder>
mkdir modules
cd modules
mkdir storageaccount
```

> The **storageaccount** folder will contain all the Terraform files for the module.

#### Define the module resources

In the **storageaccount** folder create the 3 following files for the module definition:

- **main.tf**: for the resources template
- **variables.tf**: for the variable blocks
- **outputs.tf**: for the outputs of the module

In the **variables.tf** file add the module input variables as:

```hcl
variable "resource_group_name"  {
    type = string
    description = "Name of the Resource Group for the Storage Account"
}

variable "storage_name"  {
    type = string
    description = "Name of the Storage Account to create"
}

variable "container_name" {
    type = string
    description = "Name of the Blob Container to create"
    default = "myContainer"
}
```

> For variables with no default, values must be passed when a consumer instanciates the module.  
> For variables with default values, this latter is used in case no other input is given at instantiation time.

In the **main.tf** file add the module resources definition:

```hcl
resource "azurerm_storage_account" "sa" {
  name                     = "stomodule${var.storage_name}lab" # here we use the input var value and add prefix/suffix
  resource_group_name      = var.resource_group_name
  location                 = "westeurope"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}
```

> This is a simple template to create a Storage Account and a container providing input values for the variables.

In the **outputs.tf** file define module outputs:

```hcl
output "storage_account_full_name" {
  value = azurerm_storage_account.sa.name
}

output "storage_account_id" {
  value = azurerm_storage_account.sa.id
}
```

> The module consumer cannot access the Storage Account Resource properties, unless they are output from the module.  
> We here output the full Storage Account name (will be used in module comsumer - see next exercise below).  

#### Consume the module

In the **main.tf** file at the root folder (module consumer) add the following content to consume the newly created module:

```hcl
module "storage" {
  source = "./modules/storageaccount" # we are importing Terraform module files from this location

  # specify input values for the module
  resource_group_name = data.azurerm_resource_group.rg_training.name
  storage_name = "set_your_trigram_here"
  container_name = "content" # this is not obligatory as a default value exist for the container name in the module
}
```

> We have added a new module in our Terraform templates.  
> We must start again the *init* phase to install the module before being able to use ot in plan/apply phases.

Open a shell session (bash or powershell) and run the following commands to initialize the backend (in the root folder):

PowerShell

```powershell
az login
az account set --subscription "the_training_subscription_id"
$env:ARM_SUBSCRIPTION_ID="the_training_subscription_id"
terraform init -backend-config="..\configuration\dev-backend.hcl" -reconfigure
```

Bash

```powershell
az login
az account set --subscription "the_training_subscription_id"
export ARM_SUBSCRIPTION_ID="the_training_subscription_id"
terraform init -backend-config="..\configuration\dev-backend.hcl" -reconfigure
```

> Notice the initializing module step in the init logs.

Run the following commands to create resources:

```powershell
terraform apply -var-file="..\configuration\dev.tfvars"
```

> Notice the identifier of the created resources being prefixed with `module.storage`:
>
> - `module.storage.azurerm_storage_account.sa` for the Storage Account
> - `module.storage.azurerm_storage_container.container` for the Container

### Exercise 2: Use module outputs

In this exercise, we will add a Storage Account Queue in the newly created storage.  
We will not create this resource in the module itself but in the root module.

In **main.tf** file of the root module, create the Queue with:

```hcl
resource "azurerm_storage_queue" "queue" {
  name               = "mysamplequeue"
  # we must indicate in which storage the queue is to be created
  storage_account_id = module.storage.azurerm_storage_account.sa.id
}
```

Run the following commands to create the resource:

```powershell
terraform apply -var-file="..\configuration\dev.tfvars"
```

> Notice the error!  
> We are **not able** to direclty access the Storage Account properties.
> Only module outputs are available in the module consumer.  
> Hence the outputs as defined in previous exercise...

Replace the content we added with the following block:

```hcl
resource "azurerm_storage_queue" "queue" {
  name               = "mysamplequeue"
  # here we reference the storage account id using the module output
  storage_account_id = module.storage.storage_account_id
}
```

Run the following command to create the resource:

```powershell
terraform apply -var-file="..\configuration\dev.tfvars"
```

> Success!
> We used the output of the module to get the Storage Account name.

### Exercise 3: Remove resources

Remove all the created resources using the destroy command:

```powershell
terraform destroy -var-file="..\configuration\dev.tfvars"
```
