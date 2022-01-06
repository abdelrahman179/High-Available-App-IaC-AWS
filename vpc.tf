# Create AWS VPC
resource "aws_vpc" "app-vpc" {
  cidr_block = var.vpc_cidr_block
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_classiclink = false
  tags = {
    Name = "${var.ENVIRONMENT}-app-vpc"
  }
}

# >>> Public Subnet 1 
resource "aws_subnet" "app-public-sub-1-a" {
 vpc_id = aws_vpc.app-vpc.id
 cidr_block = var.public_subnets_cidr_block[0]
 map_public_ip_on_launch = true
 availability_zone = var.AVAIL_ZONE[0]

 tags = {
     Name = "${var.ENVIRONMENT}-app-vpc-public_subnet-1"
 }
}

# >>> Public Subnet 2 
resource "aws_subnet" "app-public-sub-2-b" {
 vpc_id = aws_vpc.app-vpc.id
 cidr_block = var.public_subnets_cidr_block[1]
 map_public_ip_on_launch = true
 availability_zone = var.AVAIL_ZONE[1]

 tags = {
     Name = "${var.ENVIRONMENT}-app-vpc-public_subnet-2"
 }
}

# >>> Private Subnet 1 
resource "aws_subnet" "app-private-sub-1-a" {
 vpc_id = aws_vpc.app-vpc.id
 cidr_block = var.private_subnets_cidr_block[0]
 map_public_ip_on_launch = false
 availability_zone = var.AVAIL_ZONE[0]

 tags = {
     Name = "${var.ENVIRONMENT}-app-vpc-private_subnet-1"
 }
}

# >>> Private Subnet 2 
resource "aws_subnet" "app-private-sub-2-b" {
 vpc_id = aws_vpc.app-vpc.id
 cidr_block = var.private_subnets_cidr_block[1]
 map_public_ip_on_launch = false
 availability_zone = var.AVAIL_ZONE[1]

 tags = {
     Name = "${var.ENVIRONMENT}-app-vpc-private_subnet-2"
 }
}


# >>> Internet Gateway
resource "aws_internet_gateway" "app-vpc-igw" {
  vpc_id = aws_vpc.app-vpc.id

  tags = {
      Name = "${var.ENVIRONMENT}-app-vpc-igw"
  }
}

# >>> Routing Table
resource "aws_route_table" "app-vpc-pub-rtb" {
  vpc_id = aws_vpc.app-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.app-vpc-igw.id
  }

  tags = {
      Name = "${var.ENVIRONMENT}-app-vpc-rtb"
  }
}

# >>> Routing table association with two pub subnets
resource "aws_route_table_association" "app-vpc-pub-sub-1-a" {
  subnet_id = aws_subnet.app-public-sub-1-a.id
  route_table_id = aws_route_table.app-vpc-pub-rtb.id
}

resource "aws_route_table_association" "app-vpc-pub-sub-1-b" {
  subnet_id = aws_subnet.app-public-sub-2-b.id
  route_table_id = aws_route_table.app-vpc-pub-rtb.id
}

