# Setup environment

- [Setup environment](#setup-environment)
  - [Lab overview](#lab-overview)
  - [Objectives](#objectives)
  - [Instructions](#instructions)
    - [Before you start](#before-you-start)
    - [Exercise 1: Deploy a Storage Account in an existing Resource Group](#exercise-1-deploy-a-storage-account-in-an-existing-resource-group)
    - [Exercise 2: Update the Storage Account with Terraform](#exercise-2-update-the-storage-account-with-terraform)
    - [Exercise 3: Update the Storage Account from the portal](#exercise-3-update-the-storage-account-from-the-portal)
    - [Exercise 4: Update the Storage Account name](#exercise-4-update-the-storage-account-name)
    - [Exercise 5: Remove the Storage Account](#exercise-5-remove-the-storage-account)

## Lab overview

In this lab, you will learn how to deploy a Storage Account using terraform workflow (cli).

## Objectives

After you complete this lab, you will be able to:

-   Deploy a Storage Account
-   Understand the Terraform workflow.

## Instructions

### Before you start

- Ensure Terraform (version >= 1.0.0) is installed and available from system's PATH.
- Ensure Azure CLI is installed.
- Check your access to the Azure Subscription and Resource Group provided for this training.
- Your environment is setup and ready to use from the lab *1-Setup environment*.

### Exercise 1: Deploy a Storage Account in an existing Resource Group

1. Make the manually created Resource Group known by Terraform

Create a `data.tf` file, and add the following `data` block to reference your Storage Account:

```hcl
data "azurerm_resource_group" "training-rg" {
  name = "your_resource_group_name"
}
```

> Since this Resource Group has been created outside of Terraform, we are using a data block to retrieve its configuration.
> No change will be done on this Resource Group, this template does not manage its lifecyle.

2. Create a Storage Account in this Resource Group

Create a `storage.tf` file, and add the following `resource` block to create a Storage Account:

```hcl
resource "azurerm_storage_account" "example" {
  name                     = "myuniquenamestorageaccount" # <-- replace with a unique name
  resource_group_name      = data.azurerm_resource_group.training-rg.name
  location                 = "westeurope"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "dev"
  }
}
```

> We use the previous data block to retrieve the *resource_group_name* attribute.

Open a new shell and run the following commands:

```powershell
az login
$env:ARM_SUBSCRIPTION_ID="Id of the provided training subscription"
terraform init -backend-config=".\configuration\dev-backend.hcl"
terraform plan
```

The *tfstate* file is refreshed and compared to Terraform templates, and a plan is generated indicating infrastructure updates.  
The plan shows a new resource to create as "Plan: 1 to add, 0 to change, 0 to destroy.".  
Run the `apply` command:

```powershell
terraform apply
```

Confirm the creation, approving with *yes*.  
The *tfstate* file is updated with the new resource.  
Use the Azure portal to confirm Storage Account Creation.

### Exercise 2: Update the Storage Account with Terraform

Update the previous configuration adding a new tag in the *tags* block:

```hcl
tags = {
    environment = "dev"
    location    = "westeurope"
}
```

Run the `plan` command:

```powershell
terraform plan
```

The plan shows a single resource to update as "Plan: 0 to add, 1 to change, 0 to destroy.".
> Terraform has refreshed its state before generating its plan.  
> The plan is generated comparing the refreshed *tfstate* and the current configuration.

Run the `apply` command (and confirm):

```powershell
terraform apply
```

Use the Azure portal to confirm the tag is created on the Storage Account.

### Exercise 3: Update the Storage Account from the portal

Using the Azure portal, remove the location tag on the Storage Account.  
Then, run the `plan` command:

```powershell
terraform plan
```

The plan shows that the Storage Account needs to be updated.

> Terraform has refreshed its state before generating its plan: the update done using the Azure portal is seen as a difference between the Terraform template configuration, and the real world.  

Run the `apply` command (and confirm):

```powershell
terraform apply
```

Use the Azure portal to confirm the tag has been (re)created.

### Exercise 4: Update the Storage Account name

Update the previous configuration and change the name of the Storage Account:

```hcl
name = "myuniquenamestorageaccountbutdifferent"
```

Run the `plan` command:

```powershell
terraform plan
```

The plan is indicating a resource to delete and a resource to create "Plan: 1 to add, 0 to change, 1 to destroy.".

> The azurerm provider will always try to perform update in-place actions. When it's not possible (changing the name of a resource for instance), a delete/create operation is done.

Run the `apply` command (and confirm):

```powershell
terraform apply
```

Use the Azure portal to confirm that the existing Storage Account has been deleted and a new one created.

### Exercise 5: Remove the Storage Account

Run the `destroy` command:

```powershell
terraform destroy
```

The plan is indicating a resource to delete "Plan: 0 to add, 0 to change, 1 to destroy.".
Confirm the deletion, approving with *yes*.

Note:
> `apply` and `destroy` commands accept an `-auto-approve` option to the command line that avoids querying for user validation.  
> This is to be used carefully, e.g. to avoid accidently deleting resources.

Use the Azure portal to confirm Storage Account deletion.
