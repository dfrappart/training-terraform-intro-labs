# Setup environment

## Lab overview

In this lab, you will learn how to deploy a Storage Account and use terraform cli.

## Objectives

After you complete this lab, you will be able to:

-   Deploy a Storage Account
-   Understand the Terraform worklow

## Instructions

### Before you start

- Ensure Terraform (version >= 1.0.0) is installed and available from system's PATH.
- Ensure Azure CLI is installed.
- Check your access to the Azure Subscription and Resource Group provided for this training.
- Your environment is setup and ready to use from the lab *Setup environment*

### Exercise 1: Deploy a Storage Account

In the *main.tf* file, add the following **data** block to reference your Storage Account

```hcl
data "azurerm_resource_group" "training-rg" {
  name = "your_resource_group_name"
}
```

> Since this Resource Group has been created outside of Terraform, we will use a data block to retrieve its configuration.

> No change will be done on this Resource Group, this template does not manage its lifecyle.

Add the following **resource** block to create a Storage Account

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

> We use the previous data block to retrieve the resource_group_name attribut.

Open a new shell and run the following commands:

```powershell
az login
$env:ARM_SUBSCRIPTION_ID="Id of the provided training subscription"
terraform init -backend-config=".\configuration\dev-backend.hcl"
terraform plan
```

The tfstate file is refreshed and a plan is generated indicating infrastructure updates.

The plan is indicating a resource to create

Run the apply command

```powershell
terraform apply
```

Confirm the creation, approving with *yes*

Use the Azure portal to confirm Storage Account Creation

### Exercise 2: Update the Storage Account

Update the previous configuration and add a new tag in the *tags* block

```hcl
tags = {
    environment = "dev"
    location = "westeurope"
}
```

Run the Plan command

```powershell
terraform plan
```

The plan is indicating a single resource to update

> Terraform has refreshed its state before generating its plan. The plan is generated comparing the refreshed tfstate and the current configuration.

Run the apply command

```powershell
terraform apply
```

Use the Azure portal to confirm the tag is created on the Storage Account

### Exercise 3: Update the Storage Account from the portal

Using the Azure Portal, remove the location tag on the Storage Account

Run the Plan command

```powershell
terraform plan
```

The plan is indicating that the Storage Account needs to be updated

> Terraform has refreshed its state before generating its plan, including the update done in the portal.

Run the apply command

```powershell
terraform apply
```

Use the Azure portal to confirm tag has been created

### Exercise 4: Update the Storage Account name

Update the previous configuration and change the name of the Storage Account

```hcl
name = "myuniquenamestorageaccountbutdifferent"
```

Run the Plan command

```powershell
terraform plan
```

The plan is indicating a resource to delete and a resource to create

> The azurerm provider will always try to perform update in-place actions. When it's not possible (changing the name of a resource for instance), a delete / create operation is done.

Run the apply command

```powershell
terraform apply
```

Use the Azure portal to confirm that the existing Storage Account has been deleted and a new on created

### Exercise 5: Remove the Storage Account

Run the destroy command

```powershell
terraform destroy
```

The plan is indicating a resource to delete

Confirm the deletion, approving with *yes*

> For apply and destroy command, you can add the -auto-approve to the command line the avoid validaton

Use the Azure portal to confirm Storage Account deletion
