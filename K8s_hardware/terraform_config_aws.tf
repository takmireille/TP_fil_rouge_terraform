# 
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
  access_key = "your acces_key"
  secret_key = "your secret_key"
}
################################## network ########################################################
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
############################################################ instences ec2 (VM)################################
# Création des clés SSH
resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_k8s"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCn311NHCyq7GFNrqobZ1O7XuevWQKSIgsef99zq+ZJfUvGl5akTi/HI1lyL6sNP+cQ2wU5C+pE2dfnqdNk1LTuOyQjjinISGPL94mswJ4lvVK6oeclYkmnG/mro4Yii0WuEjEWMkWlx7vA16f/o1Oxt1uOvwobxRPG71MeKJs0J1Uv/Qp/U1dnkb6ew6TiglZ8qGWAZwJpPvgjF7Y26gKKWDNqHuwuCCAYRtTa/mRo4HJQ5iw8CzyMrrZEchxZkOkj+dth2h3Su0v+fTz7JE2IFlKU4KsCPAnVgUcaL37xyaRXY99nh0wcp7zqvjHKfZu8AutnppZpi8TtzgE/vIaASs9D4bUDTmJq8aC4HGXCKSBOFtZhWHykMxaPiTprz+/cZDfGqbqQmHrB5weyauWj5t8c2mT8m7nhEM42tklqOav+zD3ouvUTnWvMrmUBLU7vGK+p1GeWILIxqwvpLef67SyUKyuzckBZYY/y7S/FBVyafhBpqybSN/UwfhX7qX8= administrateur@ACT14"
}
# Creer security group
resource "aws_security_group" "allow_ssh_http" {
  name        = "Web_SG"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.k8s_M_vpc.id
  ingress {
    description      = "Allow All"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = [ "0.0.0.0/0" ]
  }
  ingress {
    description      = "Allow All"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = [ "0.0.0.0/0" ]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "K8S_M_SG"
  }
}

# Création de l'instance master
resource "aws_instance" "master_instance" {
  ami           = "ami-05b5a865c3579bbc4" 
  instance_type = "t2.micro" 
  security_groups = [ aws_security_group.allow_ssh_http.id]
  subnet_id     = aws_subnet.Mir.id
  key_name      = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  tags = {
    Name = "Master-k8s-Instance"
  }
}

# Création de l'instance worker
resource "aws_instance" "worker_instance" {
  ami           = "ami-05b5a865c3579bbc4"
  instance_type = "t2.micro" 
  security_groups = [ aws_security_group.allow_ssh_http.id ]
  subnet_id     = aws_subnet.Mir.id
  key_name      = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  tags = {
     Name = "Worker-k8-Instance"
  } 
  }
