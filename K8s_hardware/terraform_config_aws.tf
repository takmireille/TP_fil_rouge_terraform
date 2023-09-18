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
  region     = "choose your region"
  access_key = "your acces key"
  secret_key = "your secret key"
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

 
resource "aws_subnet" "Mir" {
  vpc_id     = aws_vpc.k8s_M_vpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "Mir-ter-K8s"
  }

  depends_on = [ aws_vpc.k8s_M_vpc ]
}

# creation d'une internet-gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.k8s_M_vpc.id
  tags = {
    Name = "K8S-int-gateway"
  }

  depends_on = [ aws_vpc.k8s_M_vpc ]
}

# Création de la table de routage
resource "aws_route_table" "K8S-route_table" {
  vpc_id = aws_vpc.k8s_M_vpc.id
  tags = {
    Name = "K8S-route_table"
  }
}

# Association des sous-réseaux à la table de routage
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.Mir.id
  route_table_id = aws_route_table.K8S-route_table.id

  depends_on = [ aws_subnet.Mir ]
}

# Ajout de la route par défaut vers la gateway Internet
resource "aws_route" "K8S-route_table" {
  route_table_id         = aws_route_table.K8S-route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# Création des clés SSH
resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = file("~/.ssh/id_rsa.pub")
}


# Création de l'instance master
resource "aws_instance" "master_instance" {
  ami           = "ami-05b5a865c3579bbc4" 
  instance_type = "t2.micro" 
  subnet_id     = aws_subnet.Mir.id
  key_name      ="ssh_key"
  tags = {
    Name = "Master-k8s-Instance"
  }
}

# Création de l'instance worker
resource "aws_instance" "worker_instance" {
  ami           = "ami-05b5a865c3579bbc4" 
  instance_type = "t2.micro" 
  subnet_id     = aws_subnet.Mir.id
  key_name      = "ssh_key"
  tags = {
     Name = "Worker-k8-Instance"
  } 
  }
