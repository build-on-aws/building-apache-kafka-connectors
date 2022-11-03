###########################################
################# General #################
###########################################

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = var.global_prefix
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = var.global_prefix
  }
}

resource "aws_eip" "default" {
  depends_on = [aws_internet_gateway.default]
  vpc = true
  tags = {
    Name = var.global_prefix
  }
}

resource "aws_route" "default" {
  route_table_id = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.default.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "${var.global_prefix}-private-route-table"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_route_table_association" "private_subnet_association" {
  count = length(data.aws_availability_zones.available.names)
  subnet_id = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}

###########################################
################# Subnets #################
###########################################

variable "private_cidr_blocks" {
  type = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]
}

resource "aws_subnet" "private_subnet" {
  count = 3
  vpc_id = aws_vpc.default.id
  cidr_block = element(var.private_cidr_blocks, count.index)
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.global_prefix}-private-subnet-${count.index}"
  }
}

resource "aws_subnet" "bastion_host_subnet" {
  vpc_id = aws_vpc.default.id
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.global_prefix}-bastion-host"
  }
}

###########################################
############# Security Groups #############
###########################################

resource "aws_security_group" "kafka" {
  name = "${var.global_prefix}-kafka"
  vpc_id = aws_vpc.default.id
  ingress {
    from_port = 0
    to_port = 9092
    protocol = "TCP"
    cidr_blocks = ["10.0.1.0/24",
                   "10.0.2.0/24",
                   "10.0.3.0/24"]
  }
  ingress {
    from_port = 0
    to_port = 9092
    protocol = "TCP"
    cidr_blocks = ["10.0.4.0/24"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.global_prefix}-kafka"
  }
}

resource "aws_security_group" "connector" {
  name = "${var.global_prefix}-connector"
  vpc_id = aws_vpc.default.id
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.global_prefix}-connector"
  }
}

resource "aws_security_group" "bastion_host" {
  name = "${var.global_prefix}-bastion-host"
  vpc_id = aws_vpc.default.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.global_prefix}-bastion-host"
  }
}
