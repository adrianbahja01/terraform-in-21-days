resource "aws_vpc" "vpc_adrian" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.project_name}_vpc"
  }
}
resource "aws_subnet" "public" {
  count             = length(var.public_cidr)
  cidr_block        = var.public_cidr[count.index]
  vpc_id            = aws_vpc.vpc_adrian.id
  availability_zone = var.availability_zone_names[count.index]

  tags = {
    Name = "${var.project_name}_public${count.index}"
  }
}
resource "aws_subnet" "private" {
  count             = length(var.private_cidr)
  cidr_block        = var.private_cidr[count.index]
  vpc_id            = aws_vpc.vpc_adrian.id
  availability_zone = var.availability_zone_names[count.index]

  tags = {
    Name = "${var.project_name}_private${count.index}"
  }
}

resource "aws_internet_gateway" "internet" {
  vpc_id = aws_vpc.vpc_adrian.id

  tags = {
    Name = "${var.project_name}_internet"
  }
}

resource "aws_eip" "eip" {
  count  = length(var.public_cidr)
  vpc = true

  tags = {
    Name = "${var.project_name}_eip${count.index}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.public_cidr)
  subnet_id     = aws_subnet.public[count.index].id
  allocation_id = aws_eip.eip[count.index].id

  tags = {
    Name = "${var.project_name}_nat${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc_adrian.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet.id
  }

  tags = {
    Name = "${var.project_name}_public"
  }
}

resource "aws_route_table" "private" {
  count  = length(var.private_cidr)
  vpc_id = aws_vpc.vpc_adrian.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = {
    Name = "${var.project_name}_private${count.index}"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_cidr)
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = length(var.public_cidr)
  route_table_id = aws_route_table.private[count.index].id
  subnet_id      = aws_subnet.private[count.index].id
}

