resource "aws_vpc" "vpc_project" {
  cidr_block = "172.31.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "testing_vpc_project"
  }
}
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc_project.id

  tags = {
    Name = "testing_internet_gateway"
  }
}

resource "aws_route_table" "internet_route_table" {
  vpc_id = aws_vpc.vpc_project.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id  = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "testing_internet_route_table"
  }
}

resource "aws_route_table_association" "internet_route_association" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.internet_route_table.id
}

resource "aws_subnet" "subnet_public" {
  vpc_id                  = aws_vpc.vpc_project.id
  cidr_block              = "172.31.0.0/20"
  availability_zone       = "us-east-2a"

  tags = {
    Name = "testing_subnet_public"
  }
}

