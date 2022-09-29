variable "locations" {
  default = ["westeurope", "northeurope"]
}

variable "vnet-address-space" {
  default = ["10.0.0.0/16"]
}

variable "subnet-address-prefixes" {
  default = ["10.0.0.0/24"]
}

variable "count-of-vms-per-subnet" {
  default = 2
}

variable "dns-zone" {
  default = "oleksandr-zhydkov.com"
}

variable "deploy-file-name" {
  default = "iis-deploy.ps1"
}