terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
# aws credential
provider "aws" {
  region     = "eu-west-3"
  access_key = "AKIATOW4MSGJUMHVRNZQ"
  secret_key = "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"
}

# creation du vpc
resource "aws_vpc" "k8s_M_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "K8S_M_VPC"
  }
}
# creer les sous reseaux
resource "aws_subnet" "subnet_K8S" {
  count                   = 2
  vpc_id                  = 0d04a13ed9ca964fb
  cidr_block              = element(["10.0.1.0/24", "10.0.2.0/24"], count.index)
  availability_zone       = element(["eu-west-3", "eu-west-3"], count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet_K8s_M-${count.index}"
  }
  
}
