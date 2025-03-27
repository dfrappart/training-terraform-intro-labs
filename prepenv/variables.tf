######################################################
# Variables
######################################################

##############################################################
#Variable declaration for provider

variable "AzureSubscriptionID" {
  type        = string
  description = "The subscription id for the authentication in the provider"
}

variable "AzureClientID" {
  type        = string
  description = "The application Id, taken from Azure AD app registration"
}


variable "AzureClientSecret" {
  type        = string
  description = "The Application secret"

}

variable "AzureTenantID" {
  type        = string
  description = "The Azure AD tenant ID"
}


variable "AzureADClientSecret" {
  type        = string
  description = "The AAD Application secret"

}

variable "AzureADClientID" {
  type        = string
  description = "The AAD Client ID"
}




######################################################
# Common variables

variable "AzureRegion" {
  type        = string
  description = "The region for the Azure resource"
  default     = "eastus"

}


######################################################
# Training

variable "TrainingList" {
  type        = list(any)
  description = "The trainee list"
  default = [
    "peter.parker",
    "bruce.wayne",
    "clark.kent",
    "diana.prince",
    "barry.allen",
    "hal.jordan",]
}

variable "TrainingGroup" {
  type = string
  description = "The group ID for the training"
}