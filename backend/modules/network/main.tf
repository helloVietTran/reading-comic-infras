############################################
# VPC
############################################

resource "aws_vpc" "this" {

  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(var.tags, {
    Name = "${var.project_name}-vpc"
  })
}

############################################
# Internet Gateway
############################################

resource "aws_internet_gateway" "this" {

  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-igw"
  })
}

############################################
# Public Subnets
############################################

resource "aws_subnet" "public" {

  for_each = var.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = each.value.name
  })
}

############################################
# Private Subnets
############################################

resource "aws_subnet" "private" {

  for_each = var.private_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.tags, {
    Name = each.value.name
  })
}

############################################
# Elastic IP
############################################

resource "aws_eip" "nat" {

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.project_name}-nat-eip"
  })

  depends_on = [
    aws_internet_gateway.this
  ]
}

############################################
# NAT Gateway
############################################

resource "aws_nat_gateway" "this" {

  allocation_id = aws_eip.nat.id

  subnet_id = aws_subnet.public["public_1"].id

  tags = merge(var.tags, {
    Name = "${var.project_name}-nat"
  })

  depends_on = [
    aws_internet_gateway.this
  ]
}

############################################
# Public Route Table
############################################

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-public-rt"
  })
}

############################################
# Private Route Table
############################################

resource "aws_route_table" "private" {

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-private-rt"
  })
}

############################################
# Public Route Table Association
############################################

resource "aws_route_table_association" "public" {

  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

############################################
# Private Route Table Association
############################################

resource "aws_route_table_association" "private" {

  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

############################################
# Subnet group
############################################

resource "aws_db_subnet_group" "this" {

  name = "${var.project_name}-db-subnet-group"

  subnet_ids = [
    aws_subnet.private["db_1"].id,
    aws_subnet.private["db_2"].id
  ]

  tags = merge(var.tags,{
    Name = "${var.project_name}-db-subnet-group"
  })
}

resource "aws_elasticache_subnet_group" "this" {

  name = "${var.project_name}-redis-subnet-group"

  subnet_ids = [
    aws_subnet.private["db_1"].id,
    aws_subnet.private["db_2"].id
  ]

  tags = merge(var.tags, {
    Name = "${var.project_name}-redis-subnet-group"
  })
}