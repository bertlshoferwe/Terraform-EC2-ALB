//Main VPC
resource "aws_vpc" "mainVPC" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

}

//Security group
resource "aws_security_group" "SG1" {
  name        = "SG1"
  vpc_id      = aws_vpc.mainVPC.id

//What traffic is allowed in
  ingress  {
    description = "HTTP from VPC"
    from_port = 80
    to_port = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress  {
    description = "SSH from VPC"
    from_port = 22
    to_port = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

//What traffic is allowed out
  egress  {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//Subnets 
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.mainVPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.mainVPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

//Internet gateway
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_security_group.SG1.id
}

//Route Table
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.mainVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
}

//Associate the subnets with the route table
resource "aws_route_table_association" "RTA1" {
  subnet_id = aws_subnet.subnet1.id
  route_table_id = aws_route_table.RT.id
} 
resource "aws_route_table_association" "RTA2" {
  subnet_id = aws_subnet.subnet2.id
  route_table_id = aws_route_table.RT.id
} 
