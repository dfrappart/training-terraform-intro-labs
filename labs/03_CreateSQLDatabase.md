# Setup environment

## Lab overview

In this lab, you will learn how to deploy an Azure SQL Database and use variables.

## Objectives

After you complete this lab, you will be able to:

-   Deploy an Azure SQL Database
-   Manage sensitive data using environment variable
-   Work with variables
-   Use interpolation

## Instructions

### Before you start

- Ensure Terraform (version >= 1.0.0) is installed and available from system's PATH.
- Ensure Azure CLI is installed.
- Check your access to the Azure Subscription and Resource Group provided for this training.
- Your environment is setup and ready to use from the lab *Setup environment*

### Exercise 1: Deploy an Azure SQL Database

In the *main.tf* file, add the following **data** block to reference your Storage Account

```hcl
data "azurerm_resource_group" "training-rg" {
  name = "yourresourcegroupname"
}
```

> Since this Resource Group has been created outside of Terraform, we will use a data block to retrieve its configuration.

> No change will be done on this Resource Group, this template does not manage its lifecyle.

#### Add variables

In order to be more dynamic, templates use variables.

This variables can be used to use the same template for multiple environments.

Add a new file, named *variables.tf* and add this content

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
    description = "Location for resources to be created"
}
```

The terraform template now needs to have this three variables filled in order to be able to apply it.

- By an environment variable matching the name of the variable, prefixed with *TF_VAR_* (for example TF_VAR_project_name="myproject")
- with a -var option in the command line (for example -var='project_name="myproject"')
- with a -var-file option in the command line, providing a link to a *.tfvars* file (for example -var-file=".\configuration\training.tfvars")


> Since admin_account_login has a default value, it is not mandatory to provide one.

We will use a tfvars file for admin_account_login, project_name and location and an environment variable for admin_account_password

> Environment variable are a convenient way to manage sensitive data. There is no risk to commit them and this mechanism can easilly be included in CI/CD tools

In the configuration folder, add a new file named *dev.tfvars* and add this content

```hcl
admin_account_login = "trainingadmindb"
project_name = "sampledev_with_my_trigram"
location = "westeurope"
```

> project_name will be used to create resources with a public FQDN. Choose an unique one for your resources

#### Create Azure SQL Server and Database

In the *main.tf* file add the following blocks to create an Azure SQL Server and an Azure SQL Database

```hcl
resource "azurerm_mssql_server" "training_sql_srv" {
  name                         = "${var.project_name}-sqlsrv"
  resource_group_name          = data.azurerm_resource_group.training-rg.name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.admin_account_login
  administrator_login_password = var.admin_account_password
  minimum_tls_version          = "1.2"
}

resource "azurerm_mssql_database" "test" {
  name           = "test-db"
  server_id      = azurerm_mssql_server.training_sql_srv.id
  sku_name       = "S0"
}
```

We can use variables using the *var.name_of_the_variable* syntax.

For the name of the azurerm_mssql_server instance, we use the interpolation syntax.

#### Deploy resources

Open a new shell and run the following commands:

```powershell
az login
$env:ARM_SUBSCRIPTION_ID="Id of the provided training subscription"
$env:TF_VAR_admin_account_password="a_password_compliant_with_azure_sql_server_policy"
terraform init -backend-config=".\configuration\dev-backend.hcl" -reconfigure
terraform plan -var-file=".\configuration\dev.tfvars"
```

The plan is indicating two resources to create

Run the apply command

```powershell
terraform apply -var-file=".\configuration\dev.tfvars"
```

Confirm the creation, approving with *yes*

Use the Azure portal to confirm resources creation


#### Remove resources

Run the destroy command

```powershell
terraform destroy -var-file=".\configuration\dev.tfvars"
```

The plan is indicating resources to delete

Confirm the deletion, approving with *yes*

> For apply and destroy command, you can add the -auto-approve to the command line the avoid validaton

Use the Azure portal to confirm resources deletion

### Exercise 2: Deploy another environment

In order to deploy another environment, backend and tfvars file should be created

#### Create backend configuration

In the *configuration* folder, create a new file named *prod-backend.hcl* with the following content

```hcl
resource_group_name  = "name of the Resource Group of the Storage Account"
storage_account_name = "name of the Storage Account"
container_name       = "Name of the container"
key                  = "training-prod.tfstate"
```

In the *configuration* folder, create a new file named *prod.tfvars* with the following content

```hcl
admin_account_login = "trainingadmindb"
project_name = "[a project name]prod"
location = "westeurope"
```

#### Deploy resources

In a new shell, run the following command in sequence

```powershell
az login
$env:ARM_SUBSCRIPTION_ID="Id of the provided training subscription"
$env:TF_VAR_admin_account_password="a_password_compliant_with_azure_sql_server_policy_but_not_the_same_used_for_dev"
terraform init -backend-config=".\configuration\prod-backend.hcl" -reconfigure
terraform plan -var-file=".\configuration\prod.tfvars"
terraform apply -var-file=".\configuration\prod.tfvars"
```

> Prod environment has its own backend configuration and tfvars file. It could be deployed in another subscription

#### Remove resources

In a new shell, run the following command in sequence

```powershell
az login
$env:ARM_SUBSCRIPTION_ID="Id of the provided training subscription"
$env:TF_VAR_admin_account_password="a_password_compliant_with_azure_sql_server_policy_but_not_the_same_used_for_dev"
terraform init -backend-config=".\configuration\prod-backend.hcl" -reconfigure
terraform destroy -var-file=".\configuration\prod.tfvars"
```

