# Setup environment

- [Setup environment](#setup-environment)
  - [Lab overview](#lab-overview)
  - [Objectives](#objectives)
  - [Instructions](#instructions)
    - [Before you start](#before-you-start)
    - [Exercise 1: Deploy an Azure SQL Database](#exercise-1-deploy-an-azure-sql-database)
      - [Use your existing Resource Group](#use-your-existing-resource-group)
      - [Add variables](#add-variables)
      - [Create Azure SQL Server and Database](#create-azure-sql-server-and-database)
      - [Deploy resources](#deploy-resources)
      - [Remove resources](#remove-resources)
    - [Exercise 2: Deploy another environment](#exercise-2-deploy-another-environment)
      - [Create backend and tfvars configurations for prod](#create-backend-and-tfvars-configurations-for-prod)
      - [Deploy resources](#deploy-resources-1)
      - [Remove resources](#remove-resources-1)

## Lab overview

In this lab, you will learn how to deploy an Azure SQL Database and use Terraform variables.

## Objectives

After you complete this lab, you will be able to:

-   Deploy an Azure SQL Database
-   Manage sensitive data using environment variable
-   Work with variables
-   Use interpolation.

## Instructions

### Before you start

- Ensure Terraform (version >= 1.0.0) is installed and available from system PATH.
- Ensure Azure CLI is installed.
- Check your access to the Azure Subscription and Resource Group provided for this training.
- Your environment is setup and ready to use from the lab *1-Setup environment*.

### Exercise 1: Deploy an Azure SQL Database

#### Use your existing Resource Group

Create a `data.tf` file, and add the following `data` block to reference your Resource Group:

```hcl
data "azurerm_resource_group" "rg_training" {
  name = "your_resource_group_name"
}
```

> Since this Resource Group has been created outside of Terraform, we are using a data block to retrieve its configuration.  
> No change will be done on this Resource Group, this template does not manage its lifecyle.

#### Add variables

In order to be more dynamic, Terraform templates can use variables.  
Variables are useful to be able to use the same Terraform template files for multiple environments.  

Create a new `variables.tf` file, and add this content:

```hcl
variable "admin_account_login" {
    type = string
    description = "Admin account login"
    default = "trainingadmindb"
}

variable "admin_account_password" {
    type = string
    description = "Admin account password"    
}

variable "project_name" {
    type = string
    description = "Name of the project"
}

variable "location" {
    type = string
    description = "Location for the to-be-created resources"
}
```

The Terraform template needs values for these three variables in order to use them.  

Setting values for variables can be done using different ways:
- Through an environment variable matching the name of the variable, prefixed with *TF_VAR_* (for example `TF_VAR_project_name="myproject"`)
- thanks to a `-var` option in the command line (for example `-var='project_name="myproject"'`)
- thanks to a `-var-file` option in the command line, providing the path to a *.tfvars* file (for example `-var-file=".\configuration\training.tfvars"`) ; this file is to be provided at `plan` and `apply` phases.

Variables are referenced within Terraform template files as attributes on an object named `var`, e.g. `var.project_name`.

We will use a *tfvars* file for `admin_account_login`, `project_name` and `location` and an environment variable for `admin_account_password`.  
> Environment variables are a convenient way to manage sensitive data. There is no risk to commit them and this mechanism can easily be included in CI/CD tools.
> Note that since `admin_account_login` has a declared default value, it is not mandatory to provide a new one.

In the *configuration* folder, create a file named `dev.tfvars` and add this content:

```hcl
admin_account_login = "trainingadmindb"
project_name = "sampledev_with_my_trigram" # <-- replace with a unique name
location = "westeurope"
```

> `project_name` will be used to create resources with a public FQDN: choose an unique one for your resources.

#### Create Azure SQL Server and Database

Create a `db.tf` file, and add the following blocks to create an Azure SQL Server and an Azure SQL Database:

```hcl
resource "azurerm_mssql_server" "training_sql_srv" {
  name                         = "${var.project_name}-sqlsrv"
  resource_group_name          = data.azurerm_resource_group.rg_training.name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.admin_account_login
  administrator_login_password = var.admin_account_password
  minimum_tls_version          = "1.2"
}

resource "azurerm_mssql_database" "training_db" {
  name           = "test-db"
  server_id      = azurerm_mssql_server.training_sql_srv.id
  sku_name       = "S0"
}
```

We can use variables using the `var.name_of_the_variable` syntax.  
For the name of the `azurerm_mssql_server` instance, we use the interpolation syntax `${var.project_name}-sqlsrv`.  
> A `${ ... }` sequence is an interpolation, which evaluates the expression given between the markers, converts the result to a string if necessary, and then inserts it into the final string.

#### Deploy resources

Open a new shell and run the following commands:

```powershell
az login
$env:ARM_SUBSCRIPTION_ID="Id of the provided training subscription"
$env:TF_VAR_admin_account_password="a_password_compliant_with_azure_sql_server_policy"
terraform init -backend-config=".\configuration\dev-backend.hcl" [-reconfigure]
terraform plan -var-file=".\configuration\dev.tfvars"
```

The plan is indicating two resources to create "Plan: 2 to add, 0 to change, 0 to destroy.".  

Run the `apply` command:

```powershell
terraform apply -var-file=".\configuration\dev.tfvars"
```

Confirm the creation (*yes* response).  
Use the Azure portal to confirm resources creation.

#### Remove resources

Run the `destroy` command:

```powershell
terraform destroy -var-file=".\configuration\dev.tfvars"
```

The plan is indicating resources to delete.  
Confirm the deletion (*yes* response).

Note:
> `apply` and `destroy` commands accept an `-auto-approve` option to the command line that avoids querying for user validation.  
> This is to be used carefully, e.g. to avoid accidently deleting resources.

Use the Azure portal to confirm resources deletion.

### Exercise 2: Deploy another environment

In order to deploy another environment, specific *backend* and *tfvars* files for this new environment must be created.

#### Create backend and tfvars configurations for prod

In the *configuration* folder, create a new file named `prod-backend.hcl` with the following content

```hcl
resource_group_name  = "name of the Resource Group of the Storage Account"
storage_account_name = "name of the Storage Account"
container_name       = "Name of the container"
key                  = "training-prod.tfstate"
```

In the *configuration* folder, create a new file named `prod.tfvars` with the following content

```hcl
admin_account_login = "trainingadmindb"
project_name = "[a project name]prod"
location = "westeurope"
```

#### Deploy resources

In a new shell, run the following command in sequence:

```powershell
az login
$env:ARM_SUBSCRIPTION_ID="Id of the provided training subscription"
$env:TF_VAR_admin_account_password="a_password_compliant_with_azure_sql_server_policy_but_not_the_same_used_for_dev"
terraform init -backend-config=".\configuration\prod-backend.hcl" -reconfigure
terraform plan -var-file=".\configuration\prod.tfvars"
terraform apply -var-file=".\configuration\prod.tfvars"
```

> Prod environment has its own *backend configuration* and *tfvars* files. It can be deployed within another subscription (e.g. accordingly setting the `ARM_SUBSCRIPTION_ID` environment variable).

#### Remove resources

In a (new) shell, run the following command in sequence

```powershell
az login
$env:ARM_SUBSCRIPTION_ID="Id of the provided training subscription"
$env:TF_VAR_admin_account_password="a_password_compliant_with_azure_sql_server_policy_but_not_the_same_used_for_dev"
terraform init -backend-config=".\configuration\prod-backend.hcl" [-reconfigure]
terraform destroy -var-file=".\configuration\prod.tfvars"
```

