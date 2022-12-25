# //////////////////////////////
# VARIABLES
# //////////////////////////////
variable "aws_access_key" {}
#  default = "AKIAXFXVCGSTW5H6GAIU"
#}

variable "aws_secret_key" {}
#  default = "kkN6gGRGf4+fuWpY75b6u3GbkjYfTNGZqPB854ma"
#}

variable "ssh_key_name" {}
#  default = "tf_key"
#}

#variable "private_key_path" {}

variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "subnet1_cidr" {
  default = "172.16.0.0/24"
}

# //////////////////////////////
# PROVIDERS
# //////////////////////////////
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

# //////////////////////////////
# RESOURCES
# //////////////////////////////

# VPC
resource "aws_vpc" "vpc1" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = "true"
}

# SUBNET
resource "aws_subnet" "subnet1" {
  cidr_block = var.subnet1_cidr
  vpc_id = aws_vpc.vpc1.id
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
}

# INTERNET_GATEWAY
resource "aws_internet_gateway" "gateway1" {
  vpc_id = aws_vpc.vpc1.id
}

# ROUTE_TABLE
resource "aws_route_table" "route_table1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway1.id
  }
}

resource "aws_route_table_association" "route-subnet1" {
  subnet_id = aws_subnet.subnet1.id
  route_table_id = aws_route_table.route_table1.id
}

# SECURITY_GROUP
resource "aws_security_group" "sg-nodejs-instance" {
  name = "nodejs_sg"
  vpc_id = aws_vpc.vpc1.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet1.id
  private_ips     = ["172.16.1.50"]
  security_groups = [aws_security_group.sg-nodejs-instance.id]
}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "172.16.1.50"
  depends_on                = [aws_internet_gateway.gw]
}


resource "aws_instance" "nodejs1" {
  ami               = "ami-0b5eea76982371e91" # Ubuntu 18.04
  instance_type     =  t3.nano
  key_name          = var.ssh_key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }
}

# //////////////////////////////
# DATA
# //////////////////////////////


# //////////////////////////////
# OUTPUT
# //////////////////////////////
output "instance-dns" {
  value = aws_instance.nodejs1.public_dns
}
