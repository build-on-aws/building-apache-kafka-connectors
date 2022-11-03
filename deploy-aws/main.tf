provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "global_prefix" {
  type = string
  default = "building-apache-kafka-connectors"
}

variable "my_1st_kf_connector" {
  type = string
  default = "my-first-kafka-connector"
}
