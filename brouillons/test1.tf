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
resource "aws_subnet" "Tak" {
  vpc_id     = "vpc-0d04a13ed9ca964fb"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Tak-K8s"
  }
}
 
resource "aws_subnet" "Mir" {
  vpc_id     = "vpc-0d04a13ed9ca964fb"
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Mir-K8s"
  }
}

# creation d'une internet-gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "vpc-0d04a13ed9ca964fb"

  tags = {
    Name = "K8S-int-gateway"
  }
}

# Création de la table de routage
resource "aws_route_table" "K8S-route_table" {
  vpc_id = "vpc-0d04a13ed9ca964fb"
  tags = {
    Name = "K8S-route_table"
  }
}

# Ajout de la route par défaut vers la gateway Internet
resource "aws_route" "default_route" {
  route_table_id         = "rtb-0c5443fc0902de3fe"
  destination_cidr_block = "10.0.2.0/24"
  gateway_id             = "igw-02b034dd6f3c58a84"
}

# Association des sous-réseaux à la table de routage
resource "aws_route_table_association" "a" {
  subnet_id      = "subnet-0f652f11e32f351e8"
  route_table_id = "rtb-0c5443fc0902de3fe"
}
resource "aws_route_table_association" "b" {
  subnet_id      = "subnet-07ae948a931b04d45"
  route_table_id = "rtb-0c5443fc0902de3fe"
}
