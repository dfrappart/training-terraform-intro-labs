# Create Module

Table of Contents
=================

* [Lab overview](#lab-overview)
* [Objectives](#objectives)
* [Instructions](#instructions)
  * [Before you start](#before-you-start)
  * [Exercise 1: Setup your environment](#exercise-1-setup-your-environment)
  * [Exercise 2: Create and consume a module for Storage Account](#exercise-2-create-and-consume-a-module-for-storage-account)
    * [Create folder and files for the module](#create-folder-and-files-for-the-module)
    * [Consume this module](#consume-this-module)
  * [Exercise 3: Use module outputs](#exercise-3-use-module-outputs)
  * [Exercise 4: Remove Resources](#exercise-4-remove-resources)

## Lab overview

In this lab, you will learn how to create and consume a module.

## Objectives

After you complete this lab, you will be able to:

-   Create a module to manage Storage Account
-   Understand how to use Terraform modules

## Instructions

### Before you start

- Ensure Terraform (version >= 1.0.0) is installed and available from system's PATH.
- Ensure Azure CLI is installed.
- Check your access to the Azure Subscriptions and Resource Groups provided for this training.

### Exercise 1: Setup your environment

In the *main.tf* file, add the following **data** block to reference your Storage Account

```hcl
data "azurerm_resource_group" "training_rg" {
  name = "your_resource_group_name"
}
```

> Since this Resource Group has been created outside of this Terraform template, we will use a data block to retrieve its configuration.

> No change will be done on this Resource Group, this template does not manage its lifecyle.

### Exercise 2: Create and consume a module for Storage Account

In this exercice, we will create a module for Storage Account.

This module will create a Storage Account and a blob container.

It will take as input the name of the Resource Group, the name for the storage (and add a prefix and a suffix) and the name of the blob container.

It will outputs the name of the storage.

#### Create folder and files for the module

The source of this module will be a local path.

Create a new folder, nammed **modules**, and in this folder create a folder **storageaccount**

```powershell
cd src
mkdir modules
cd modules
mkdir storageaccount
```

> This folder will contains all the terraform files for the module

In the **storageaccount** create the 3 following files

- **main.tf** : It will contains resources template
- **variables.tf** : It will contains variable blocks
- **outputs.tf** : It will contains the outputs of the module

In the **variables.tf** file add the following content

```hcl
variable "resource_group_name"  {
    type = string
    description = "Name of the Resource Group"
}

variable "storage_name"  {
    type = string
    description = "Name of the Storage Account to create"
}

variable "container_name" {
    type = string
    description = "Name of the Blob Container to create"
}
```

> This variables values should be passed when a consummer instanciate this module

In the **main.tf** file add the following content

```hcl
resource "azurerm_storage_account" "sa" {
  name                     = "stomodule${var.storage_name}lab"
  resource_group_name      = var.resource_group_name
  location                 = "westeurope"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}
```

> This is a simple template to create a Storage Account and a Container using the variables provided

In the **outputs.tf** file add the following content

```hcl
output "storage_account_full_name" {
  value = azurerm_storage_account.sa.name
}
```

> The full Storage Account name will be shared to the module consummer. The module consummer can't access all the Storage Account Resource properties

#### Consume this module

In the **main.tf** file in the root module (the src folder) add the following content

```hcl
module "storage" {
  source = "./modules/storageaccount"

  resource_group_name = data.azurerm_resource_group.self.name
  storage_name = "a_unique_name_goes_here"
  container_name = "content"
}
```

> This module block use the folder we just created as source

Run the following commands to initialize backend (in the src folder of the root module) :

```powershell
az login
az account set --subscription "the_training_subscription_id"
$env:ARM_SUBSCRIPTION_ID="the_training_subscription_id"
terraform init -backend-config="..\configuration\dev\backend.hcl" -reconfigure
```

> Notice the Initializing modules step in the init logs

Run the following commands to create resources :

```powershell
terraform apply -var-file="..\configuration\dev\dev.tfvars"
```

> Notice the identifier of the created resources, they are prefix with module.storage
> module.storage.azurerm_storage_account.sa for the Storage Account
> module.storage.azurerm_storage_container.container for the Container

### Exercise 3: Use module outputs

In this exercice, we will create a Storage Account Queue for the Storage we have provisionned.

We will create this resource in the root module.

In the **main.tf** file of the root module, add the following content to create the Queue

```hcl
resource "azurerm_storage_queue" "queue" {
  name                 = "mysamplequeue"
  storage_account_name = module.storage.azurerm_storage_account.sa.name
}
```

Run the following commands to create resources :

```powershell
terraform apply -var-file="..\configuration\dev\dev.tfvars"
```

> Notice the error. We are not able to access the Storage Account properites directly.

> That's why we setup an ouptut for this module

Replace the content we added with this block

```hcl
resource "azurerm_storage_queue" "queue" {
  name                 = "mysamplequeue"
  storage_account_name = module.storage.storage_account_full_name
}
```

Run the following commands to create resources :

```powershell
terraform apply -var-file="..\configuration\dev\dev.tfvars"
```

> Notice the success in applying the template

> We used the output of the module in order to retrieve the Storage Account name

### Exercise 4: Remove Resources

Remove all the created resources using the destroy command

```hcl
terraform destroy -var-file="..\configuration\dev\dev.tfvars"
```