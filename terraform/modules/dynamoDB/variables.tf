variable "name" {
  type    = "string"
  default = "fruits"
}

variable "billing_mode" {
  type    = "string"
  default = "PROVISIONED"
}

variable "hash_key" {
  type    = "string"
  default = "fruitName"
}

variable "OwnerContact" {
  type    = "string"
  default = "clouddrivers"
}

variable "Environment" {
  type    = "string"
  default = "dev"
}

variable "region" {
  type    = "string"
  default = "us-east-1"
}
