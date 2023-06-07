resource "aws_vpc" "vpc_adrian" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc_adrian"
  }
}
resource "aws_subnet" "public0" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.vpc_adrian.id
  availability_zone = "us-east-1a"

  tags = {
    Name = "public0"
  }
}
resource "aws_subnet" "public1" {
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.vpc_adrian.id
  availability_zone = "us-east-1b"

  tags = {
    Name = "public1"
  }
}
resource "aws_subnet" "private0" {
  cidr_block = "10.0.3.0/24"
  vpc_id = aws_vpc.vpc_adrian.id
  availability_zone = "us-east-1a"

  tags = {
    Name = "private0"
  }
}
resource "aws_subnet" "private1" {
  cidr_block = "10.0.4.0/24"
  vpc_id = aws_vpc.vpc_adrian.id
  availability_zone = "us-east-1b"

  tags = {
    Name = "private1"
  }
}
resource "aws_internet_gateway" "internet0" {
  vpc_id = aws_vpc.vpc_adrian.id

  tags = {
    Name = "internet0"
  }
}

resource "aws_eip" "eip0" {
domain = "vpc"

tags = {
    Name = "eip0"
  }
}

resource "aws_eip" "eip1" {
domain = "vpc"

tags = {
    Name = "eip1"
  }
}

resource "aws_nat_gateway" "nat0" {
  subnet_id = aws_subnet.private0.id
  allocation_id = aws_eip.eip0.id

  tags = {
    Name = "nat0"
  }
}

resource "aws_nat_gateway" "nat1" {
  subnet_id = aws_subnet.private1.id
  allocation_id = aws_eip.eip1.id

  tags = {
    Name = "nat1"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc_adrian.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet0.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private0" {
  vpc_id = aws_vpc.vpc_adrian.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat0.id
  }
  tags = {
    Name = "private0"
  }
}

resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.vpc_adrian.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat1.id
  }
  tags = {
    Name = "private1"
  }
}

resource "aws_route_table_association" "public0" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public0.id
}

resource "aws_route_table_association" "public1" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public1.id
}

resource "aws_route_table_association" "private0" {
  route_table_id = aws_route_table.private0.id
  subnet_id = aws_subnet.private0.id
}

resource "aws_route_table_association" "private1" {
  route_table_id = aws_route_table.private1.id
  subnet_id = aws_subnet.private1.id
}