variable "client_id" {
    description = "Service principal GUID for the Azure terraform connection."
    type = "string"
}
variable "client_secret" {
    description = "Service principal password."
    type = "string"
}
variable "tenant_id" {
    description = "Tennat ID to connect to."
    type = "string"
}
variable "subscription_id" {
    description = "Azure account subscription."
    type = "string"
}

variable "region" {
    description = "Azure region location."
    type = "string"
    default = "UK South"
}

variable "os_username" {
    description = "Username for machine to be provisioned."
    type = "string"
}

variable "os_password" { 
    description = "Password for machine to be provisioned"
    type = "string"
}
