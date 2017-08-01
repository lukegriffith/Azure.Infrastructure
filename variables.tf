variable "client_id" {
    Description = "Service principal GUID for the Azure terraform connection."
}
variable "client_secret" {
    Description = "Service principal password."
}
variable "tenant_id" {
    Description = "Tennat ID to connect to."
}
variable "subscription_id" {
    Description = "Azure account subscription."
}

variable "region" {
    Description = "Azure region location."
    Default = "UK South"
}