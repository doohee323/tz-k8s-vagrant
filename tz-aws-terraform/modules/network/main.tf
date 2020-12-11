terraform {
  required_version = ">= 0.12"
}

# Internet VPC
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = var.tags
}

# Subnets
resource "aws_subnet" "main-public-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.31.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-1a"
  tags = var.tags
}

resource "aws_subnet" "main-public-3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.31.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-1c"
  tags = var.tags
}

resource "aws_subnet" "main-private-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.31.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-1a"
  tags = var.tags
}

resource "aws_subnet" "main-private-3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.31.6.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-1c"
  tags = var.tags
}

# Internet GW
resource "aws_internet_gateway" "main-gw" {
  vpc_id = aws_vpc.main.id
  tags = var.tags
}

# route tables
resource "aws_route_table" "main-public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-gw.id
  }
  tags = var.tags
}

# route associations public
resource "aws_route_table_association" "main-public-1-a" {
  subnet_id      = aws_subnet.main-public-1.id
  route_table_id = aws_route_table.main-public.id
}

resource "aws_route_table_association" "main-public-3-a" {
  subnet_id      = aws_subnet.main-public-3.id
  route_table_id = aws_route_table.main-public.id
}

  
  